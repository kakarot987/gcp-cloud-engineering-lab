#!/usr/bin/env bash
# Create an on-demand Cloud SQL backup and resolve its actual Google-assigned ID.
# Usage: ./backup-sql.sh [INSTANCE_NAME] [BACKUP_DESCRIPTION]
set -euo pipefail

INSTANCE_NAME="${1:-my-sql-instance}"
DESCRIPTION="${2:-Manual backup from script}"
PROJECT_ID="$(gcloud config get-value project 2>/dev/null)"
if [[ -z "$PROJECT_ID" || "$PROJECT_ID" == "(unset)" ]]; then
  echo "Set a project first: gcloud config set project PROJECT_ID" >&2
  exit 1
fi

if ! gcloud sql instances describe "$INSTANCE_NAME" --project="$PROJECT_ID" >/dev/null 2>&1; then
  echo "Cloud SQL instance '$INSTANCE_NAME' was not found in '$PROJECT_ID'." >&2
  exit 1
fi

# Description identifies this request without guessing a backup ID.
# gcloud sql backups create is synchronous unless --async is specified.
UNIQUE_DESCRIPTION="${DESCRIPTION} [lab-$(date -u +%Y%m%dT%H%M%SZ)-$$]"
echo "Creating billable Cloud SQL backup on $PROJECT_ID/$INSTANCE_NAME"
gcloud sql backups create \
  --instance="$INSTANCE_NAME" \
  --description="$UNIQUE_DESCRIPTION" \
  --project="$PROJECT_ID" \
  --quiet

# The API assigns the ID; wait briefly for list consistency and verify status.
BACKUP_ID=""
BACKUP_STATUS=""
for attempt in {1..12}; do
  row="$(gcloud sql backups list --instance="$INSTANCE_NAME" \
    --project="$PROJECT_ID" \
    --format='value(id,description,status)' \
    | awk -F '\t' -v expected="$UNIQUE_DESCRIPTION" '$2 == expected { print $1 "\t" $3; exit }')"
  if [[ -n "$row" ]]; then
    IFS=$'\t' read -r BACKUP_ID BACKUP_STATUS <<< "$row"
    if [[ "$BACKUP_STATUS" == "SUCCESSFUL" ]]; then
      break
    fi
    if [[ "$BACKUP_STATUS" == "FAILED" ]]; then
      echo "Backup $BACKUP_ID failed." >&2
      exit 1
    fi
  fi
  sleep 5
done

if [[ -z "$BACKUP_ID" || "$BACKUP_STATUS" != "SUCCESSFUL" ]]; then
  echo "Backup result could not be confirmed; inspect: gcloud sql backups list --instance=$INSTANCE_NAME --project=$PROJECT_ID" >&2
  exit 1
fi

echo "Backup completed: id=$BACKUP_ID instance=$INSTANCE_NAME project=$PROJECT_ID"
gcloud sql backups describe "$BACKUP_ID" \
  --instance="$INSTANCE_NAME" --project="$PROJECT_ID" \
  --format='table(id,status,createTime,maxChargeableBytes)'

echo "To inspect: gcloud sql backups describe $BACKUP_ID --instance=$INSTANCE_NAME --project=$PROJECT_ID"
echo "Restore overwrites data; review documentation and make a recovery plan before restoring."
