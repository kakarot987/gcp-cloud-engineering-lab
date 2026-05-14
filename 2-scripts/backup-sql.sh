#!/bin/bash

# GCP Associate Cloud Engineer Lab
# Script: backup-sql.sh
# Purpose: Create backup of Cloud SQL instance
# Usage: ./backup-sql.sh [INSTANCE_NAME] [BACKUP_DESCRIPTION]

set -e  # Exit on any error

# Default values
INSTANCE_NAME="${1:-my-sql-instance}"
BACKUP_DESCRIPTION="${2:-Manual backup from script}"

# Configuration
PROJECT_ID="$(gcloud config get-value project)"

echo "🚀 Creating Cloud SQL Backup"
echo "📍 Project: $PROJECT_ID"
echo "🗄️  Instance: $INSTANCE_NAME"
echo "📝 Description: $BACKUP_DESCRIPTION"
echo

# Validate inputs
if [ -z "$PROJECT_ID" ]; then
    echo "❌ Error: PROJECT_ID not set in gcloud config"
    echo "Run: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

# Check if instance exists
if ! gcloud sql instances describe "$INSTANCE_NAME" --project="$PROJECT_ID" &>/dev/null; then
    echo "❌ Error: Cloud SQL instance '$INSTANCE_NAME' does not exist"
    echo "Available instances:"
    gcloud sql instances list --project="$PROJECT_ID" --format="value(name)"
    exit 1
fi

# Get instance details
INSTANCE_INFO=$(gcloud sql instances describe "$INSTANCE_NAME" \
    --project="$PROJECT_ID" \
    --format="value(databaseVersion,region)")

DATABASE_VERSION=$(echo "$INSTANCE_INFO" | cut -d$'\t' -f1)
REGION=$(echo "$INSTANCE_INFO" | cut -d$'\t' -f2)

echo "📊 Instance Details:"
echo "   Database: $DATABASE_VERSION"
echo "   Region: $REGION"
echo

# Generate backup ID
BACKUP_ID="backup-$(date +%Y%m%d-%H%M%S)"

# Create backup
echo "💾 Creating backup: $BACKUP_ID"
gcloud sql backups create "$BACKUP_ID" \
    --instance="$INSTANCE_NAME" \
    --description="$BACKUP_DESCRIPTION" \
    --project="$PROJECT_ID" \
    --async

# Wait for backup to complete (since --async is used, we need to poll)
echo "⏳ Waiting for backup to complete..."
BACKUP_STATUS=""

while [ "$BACKUP_STATUS" != "SUCCESSFUL" ]; do
    sleep 10
    BACKUP_INFO=$(gcloud sql backups list --instance="$INSTANCE_NAME" \
        --project="$PROJECT_ID" \
        --filter="id:$BACKUP_ID" \
        --format="value(status)" \
        --limit=1)

    if [ "$BACKUP_INFO" = "FAILED" ]; then
        echo "❌ Backup failed!"
        exit 1
    fi

    if [ "$BACKUP_INFO" = "SUCCESSFUL" ]; then
        BACKUP_STATUS="SUCCESSFUL"
        echo "✅ Backup completed successfully!"
        break
    fi

    echo "   Status: $BACKUP_INFO (waiting...)"
done

# Get backup details
BACKUP_DETAILS=$(gcloud sql backups describe "$BACKUP_ID" \
    --instance="$INSTANCE_NAME" \
    --project="$PROJECT_ID" \
    --format="value(createTime,size)")

CREATE_TIME=$(echo "$BACKUP_DETAILS" | cut -d$'\t' -f1)
BACKUP_SIZE=$(echo "$BACKUP_DETAILS" | cut -d$'\t' -f2)

echo
echo "✅ Backup created successfully!"
echo
echo "📊 Backup Details:"
echo "   ID: $BACKUP_ID"
echo "   Instance: $INSTANCE_NAME"
echo "   Created: $CREATE_TIME"
echo "   Size: $BACKUP_SIZE"
echo "   Description: $BACKUP_DESCRIPTION"
echo
echo "📋 Management Commands:"
echo "   List backups: gcloud sql backups list --instance=$INSTANCE_NAME"
echo "   Describe backup: gcloud sql backups describe $BACKUP_ID --instance=$INSTANCE_NAME"
echo "   Restore from backup: gcloud sql backups restore $BACKUP_ID --restore-instance=new-instance --instance=$INSTANCE_NAME"
echo "   Delete backup: gcloud sql backups delete $BACKUP_ID --instance=$INSTANCE_NAME"
echo
echo "🔄 Automated Backup Setup:"
echo "   # Enable automated backups"
echo "   gcloud sql instances patch $INSTANCE_NAME --backup-start-time=03:00"
echo
echo "   # Set backup retention"
echo "   gcloud sql instances patch $INSTANCE_NAME --retained-backups-count=7"
echo
echo "🧪 Test restore (create new instance):"
echo "   gcloud sql instances create restored-instance \\"
echo "     --region=$REGION \\"
echo "     --database-version=$DATABASE_VERSION \\"
echo "     --backup=gs://$PROJECT_ID:us-central1:$INSTANCE_NAME/$BACKUP_ID \\"
echo "     --backup-instance=$INSTANCE_NAME"
