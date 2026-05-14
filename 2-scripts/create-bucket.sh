#!/bin/bash

# GCP Associate Cloud Engineer Lab
# Script: create-bucket.sh
# Purpose: Create Cloud Storage bucket with proper configuration
# Usage: ./create-bucket.sh [BUCKET_NAME] [LOCATION] [STORAGE_CLASS]

set -e  # Exit on any error

# Default values
BUCKET_NAME="${1:-gcp-ace-lab-$(date +%Y%m%d-%H%M%S)}"
LOCATION="${2:-us-central1}"
STORAGE_CLASS="${3:-STANDARD}"

# Configuration
PROJECT_ID="$(gcloud config get-value project)"

echo "🚀 Creating Cloud Storage Bucket"
echo "📍 Project: $PROJECT_ID"
echo "🪣  Bucket: $BUCKET_NAME"
echo "🌍 Location: $LOCATION"
echo "💾 Storage Class: $STORAGE_CLASS"
echo

# Validate inputs
if [ -z "$PROJECT_ID" ]; then
    echo "❌ Error: PROJECT_ID not set in gcloud config"
    echo "Run: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

# Validate bucket name (must be globally unique)
if [[ ! "$BUCKET_NAME" =~ ^[a-z0-9][a-z0-9._-]*[a-z0-9]$ ]]; then
    echo "❌ Error: Invalid bucket name '$BUCKET_NAME'"
    echo "Bucket names must:"
    echo "  • Be 3-63 characters long"
    echo "  • Start and end with a letter or number"
    echo "  • Contain only lowercase letters, numbers, hyphens, periods, and underscores"
    exit 1
fi

# Check if bucket already exists
if gsutil ls -b "gs://$BUCKET_NAME" &>/dev/null; then
    echo "❌ Error: Bucket '$BUCKET_NAME' already exists"
    exit 1
fi

# Create bucket
echo "🏗️  Creating bucket: gs://$BUCKET_NAME"
gsutil mb \
    -p "$PROJECT_ID" \
    -c "$STORAGE_CLASS" \
    -l "$LOCATION" \
    -b on \
    "gs://$BUCKET_NAME"

# Set uniform bucket-level access
echo "🔒 Enabling uniform bucket-level access..."
gsutil uniformbucketlevelaccess set on "gs://$BUCKET_NAME"

# Create lifecycle policy for cost optimization
LIFECYCLE_CONFIG=$(cat << EOF
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "SetStorageClass", "storageClass": "NEARLINE"},
        "condition": {"age": 30}
      },
      {
        "action": {"type": "SetStorageClass", "storageClass": "COLDLINE"},
        "condition": {"age": 90}
      },
      {
        "action": {"type": "Delete"},
        "condition": {"age": 365}
      }
    ]
  }
}
EOF
)

echo "♻️  Setting lifecycle policy..."
echo "$LIFECYCLE_CONFIG" | gsutil lifecycle set - "gs://$BUCKET_NAME"

# Enable versioning
echo "📝 Enabling versioning..."
gsutil versioning set on "gs://$BUCKET_NAME"

# Create sample files and folders
echo "📁 Creating sample structure..."

# Create folders
gsutil mkdir "gs://$BUCKET_NAME/logs/"
gsutil mkdir "gs://$BUCKET_NAME/backups/"
gsutil mkdir "gs://$BUCKET_NAME/data/"

# Create sample files
echo "This is a sample log file for GCP ACE Lab" | gsutil cp - "gs://$BUCKET_NAME/logs/sample.log"
echo "Sample data file" | gsutil cp - "gs://$BUCKET_NAME/data/sample.txt"

# Create a sample backup file
echo "Sample backup data - $(date)" | gsutil cp - "gs://$BUCKET_NAME/backups/backup-$(date +%Y%m%d).txt"

# Set CORS policy for web access (optional)
CORS_CONFIG=$(cat << EOF
[
  {
    "origin": ["*"],
    "method": ["GET"],
    "responseHeader": ["Content-Type"],
    "maxAgeSeconds": 3600
  }
]
EOF
)

echo "🌐 Setting CORS policy..."
echo "$CORS_CONFIG" | gsutil cors set - "gs://$BUCKET_NAME"

# Make sample files publicly readable (for demo purposes)
echo "🔓 Making sample files publicly readable..."
gsutil acl ch -u AllUsers:R "gs://$BUCKET_NAME/logs/sample.log"
gsutil acl ch -u AllUsers:R "gs://$BUCKET_NAME/data/sample.txt"

# Get bucket information
echo "📊 Getting bucket information..."
BUCKET_INFO=$(gsutil stat "gs://$BUCKET_NAME")

echo
echo "✅ Bucket '$BUCKET_NAME' created successfully!"
echo
echo "📊 Bucket Details:"
echo "   Name: gs://$BUCKET_NAME"
echo "   Location: $LOCATION"
echo "   Storage Class: $STORAGE_CLASS"
echo "   Uniform Access: Enabled"
echo "   Versioning: Enabled"
echo "   Lifecycle: Configured (30d → Nearline, 90d → Coldline, 365d → Delete)"
echo
echo "📁 Bucket Structure:"
echo "   gs://$BUCKET_NAME/logs/          # Application logs"
echo "   gs://$BUCKET_NAME/backups/       # Database backups"
echo "   gs://$BUCKET_NAME/data/          # Application data"
echo
echo "🔍 Sample Files:"
echo "   Public: https://storage.googleapis.com/$BUCKET_NAME/logs/sample.log"
echo "   Public: https://storage.googleapis.com/$BUCKET_NAME/data/sample.txt"
echo
echo "🛠️  Management Commands:"
echo "   List: gsutil ls gs://$BUCKET_NAME/**"
echo "   Upload: gsutil cp local-file.txt gs://$BUCKET_NAME/"
echo "   Download: gsutil cp gs://$BUCKET_NAME/file.txt ."
echo "   ACL: gsutil acl get gs://$BUCKET_NAME"
echo "   IAM: gsutil iam get gs://$BUCKET_NAME"
echo "   Delete: gsutil rm -r gs://$BUCKET_NAME"
echo
echo "💰 Cost Optimization:"
echo "   • Files move to Nearline after 30 days"
echo "   • Files move to Coldline after 90 days"
echo "   • Files deleted after 365 days"
echo
echo "🧪 Test the bucket:"
echo "   gsutil ls gs://$BUCKET_NAME/**"
echo "   curl https://storage.googleapis.com/$BUCKET_NAME/data/sample.txt"
