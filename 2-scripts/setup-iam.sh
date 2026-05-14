#!/bin/bash

# GCP Associate Cloud Engineer Lab
# Script: setup-iam.sh
# Purpose: Create service accounts and set up IAM permissions
# Usage: ./setup-iam.sh [PROJECT_ID]

set -e  # Exit on any error

# Default values
PROJECT_ID="${1:-$(gcloud config get-value project)}"

echo "🚀 Setting up IAM for GCP Lab Environment"
echo "📍 Project: $PROJECT_ID"
echo

# Validate inputs
if [ -z "$PROJECT_ID" ]; then
    echo "❌ Error: PROJECT_ID not provided and not set in gcloud config"
    echo "Usage: $0 [PROJECT_ID]"
    exit 1
fi

# Set project
echo "🔧 Setting project to: $PROJECT_ID"
gcloud config set project "$PROJECT_ID"

# Service account configurations
declare -A SERVICE_ACCOUNTS=(
    ["app-backend"]="Application backend service account"
    ["data-pipeline"]="Data pipeline service account"
    ["monitoring"]="Monitoring and logging service account"
    ["ci-cd"]="CI/CD pipeline service account"
)

# Function to create service account
create_service_account() {
    local sa_name="$1"
    local description="$2"
    local sa_email="${sa_name}@${PROJECT_ID}.iam.gserviceaccount.com"

    echo "👤 Creating service account: $sa_name"

    # Check if service account already exists
    if gcloud iam service-accounts describe "$sa_email" &>/dev/null; then
        echo "   ⚠️  Service account '$sa_name' already exists, skipping creation"
        return 0
    fi

    # Create service account
    gcloud iam service-accounts create "$sa_name" \
        --display-name="$description" \
        --description="$description"

    echo "   ✅ Created service account: $sa_email"
}

# Function to grant roles to service account
grant_roles() {
    local sa_name="$1"
    local roles=("${@:2}")
    local sa_email="${sa_name}@${PROJECT_ID}.iam.gserviceaccount.com"

    echo "🔑 Granting roles to: $sa_name"

    for role in "${roles[@]}"; do
        echo "   📋 Granting role: $role"
        gcloud projects add-iam-policy-binding "$PROJECT_ID" \
            --member="serviceAccount:$sa_email" \
            --role="$role" \
            --quiet
    done

    echo "   ✅ Roles granted successfully"
}

# Create service accounts
echo "🏗️  Creating service accounts..."

for sa_name in "${!SERVICE_ACCOUNTS[@]}"; do
    create_service_account "$sa_name" "${SERVICE_ACCOUNTS[$sa_name]}"
done

echo
echo "🔑 Granting IAM roles..."

# App Backend Service Account
grant_roles "app-backend" \
    "roles/compute.instanceAdmin" \
    "roles/storage.objectViewer" \
    "roles/cloudsql.client" \
    "roles/monitoring.metricWriter" \
    "roles/logging.logWriter"

# Data Pipeline Service Account
grant_roles "data-pipeline" \
    "roles/storage.admin" \
    "roles/bigquery.admin" \
    "roles/pubsub.publisher" \
    "roles/pubsub.subscriber" \
    "roles/dataproc.worker"

# Monitoring Service Account
grant_roles "monitoring" \
    "roles/monitoring.viewer" \
    "roles/logging.viewer" \
    "roles/compute.viewer" \
    "roles/cloudsql.viewer"

# CI/CD Service Account
grant_roles "ci-cd" \
    "roles/cloudbuild.builds.builder" \
    "roles/storage.admin" \
    "roles/artifactregistry.writer" \
    "roles/container.developer" \
    "roles/run.admin"

echo
echo "🔐 Creating service account keys (for external use)..."

# Create keys directory
KEYS_DIR="./service-account-keys"
mkdir -p "$KEYS_DIR"

# Function to create service account key
create_sa_key() {
    local sa_name="$1"
    local sa_email="${sa_name}@${PROJECT_ID}.iam.gserviceaccount.com"
    local key_file="$KEYS_DIR/${sa_name}-key.json"

    echo "🔑 Creating key for: $sa_name"

    # Create key
    gcloud iam service-accounts keys create "$key_file" \
        --iam-account="$sa_email" \
        --key-file-type=json

    echo "   ✅ Key saved to: $key_file"
    echo "   ⚠️  WARNING: Store this key securely and never commit to version control!"
}

# Create keys for service accounts that need external access
create_sa_key "app-backend"
create_sa_key "data-pipeline"

echo
echo "👥 Setting up user roles (optional - requires user email)..."

# Function to grant user roles (commented out - requires user input)
grant_user_roles() {
    local user_email="$1"

    if [ -n "$user_email" ]; then
        echo "👤 Granting roles to user: $user_email"

        # Developer role
        gcloud projects add-iam-policy-binding "$PROJECT_ID" \
            --member="user:$user_email" \
            --role="roles/editor" \
            --quiet

        # Storage admin
        gcloud projects add-iam-policy-binding "$PROJECT_ID" \
            --member="user:$user_email" \
            --role="roles/storage.admin" \
            --quiet

        echo "   ✅ User roles granted"
    fi
}

# Uncomment and modify with actual user email if needed
# grant_user_roles "your-email@example.com"

echo
echo "📋 Creating custom roles (optional)..."

# Example custom role for read-only access
CUSTOM_ROLE_YAML=$(cat << EOF
title: "Custom Read Only"
description: "Custom role for read-only access to GCP resources"
stage: "GA"
includedPermissions:
- compute.instances.get
- compute.instances.list
- storage.buckets.get
- storage.buckets.list
- storage.objects.get
- storage.objects.list
EOF
)

# Uncomment to create custom role
# echo "🔧 Creating custom role: customReadOnly"
# gcloud iam roles create customReadOnly \
#     --project="$PROJECT_ID" \
#     --file=<(echo "$CUSTOM_ROLE_YAML")

echo
echo "✅ IAM Setup Complete!"
echo
echo "📊 Summary:"
echo "   Project: $PROJECT_ID"
echo "   Service Accounts Created: ${#SERVICE_ACCOUNTS[@]}"
echo
echo "👤 Service Accounts:"
for sa_name in "${!SERVICE_ACCOUNTS[@]}"; do
    sa_email="${sa_name}@${PROJECT_ID}.iam.gserviceaccount.com"
    echo "   • $sa_name: $sa_email"
done
echo
echo "🔑 Service Account Keys:"
echo "   📁 Location: $KEYS_DIR/"
echo "   ⚠️  IMPORTANT: Keys are sensitive - store securely!"
echo
echo "🔍 To verify IAM setup:"
echo "   gcloud iam service-accounts list"
echo "   gcloud projects get-iam-policy $PROJECT_ID --flatten='bindings[].members' --filter='bindings.members~serviceAccount'"
echo
echo "🧪 Test service account permissions:"
echo "   gcloud compute instances list --account=app-backend@$PROJECT_ID.iam.gserviceaccount.com"
echo
echo "🧹 Cleanup (if needed):"
echo "   rm -rf $KEYS_DIR/"
echo "   gcloud iam service-accounts delete app-backend@$PROJECT_ID.iam.gserviceaccount.com"
