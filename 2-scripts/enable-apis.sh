#!/bin/bash

# GCP Associate Cloud Engineer Lab
# Script: enable-apis.sh
# Purpose: Enable commonly used GCP APIs for the lab environment
# Usage: ./enable-apis.sh [PROJECT_ID]

set -e  # Exit on any error

# Default values
PROJECT_ID="${1:-$(gcloud config get-value project)}"

echo "🚀 Enabling GCP APIs for Lab Environment"
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

# Core APIs (always needed)
CORE_APIS=(
    "compute.googleapis.com"           # Compute Engine
    "storage-api.googleapis.com"       # Cloud Storage
    "storage-component.googleapis.com" # Cloud Storage
    "iam.googleapis.com"               # Identity and Access Management
    "iamcredentials.googleapis.com"    # IAM Service Account Credentials
    "cloudresourcemanager.googleapis.com" # Resource Manager
    "serviceusage.googleapis.com"      # Service Usage
)

# Database APIs
DATABASE_APIS=(
    "sqladmin.googleapis.com"          # Cloud SQL
    "firestore.googleapis.com"         # Firestore
    "bigtable.googleapis.com"          # Cloud BigTable
    "redis.googleapis.com"             # Memorystore (Redis)
    "memcache.googleapis.com"          # Memorystore (Memcached)
)

# Container & Serverless APIs
CONTAINER_APIS=(
    "container.googleapis.com"         # Google Kubernetes Engine
    "run.googleapis.com"               # Cloud Run
    "cloudfunctions.googleapis.com"    # Cloud Functions
    "cloudbuild.googleapis.com"        # Cloud Build
    "artifactregistry.googleapis.com"  # Artifact Registry
)

# Networking APIs
NETWORKING_APIS=(
    "vpcaccess.googleapis.com"         # VPC Access
    "networkservices.googleapis.com"   # Network Services
)

# Monitoring & Logging APIs
OBSERVABILITY_APIS=(
    "monitoring.googleapis.com"        # Cloud Monitoring
    "logging.googleapis.com"           # Cloud Logging
    "cloudtrace.googleapis.com"        # Cloud Trace
    "cloudprofiler.googleapis.com"     # Cloud Profiler
)

# Development APIs
DEVELOPMENT_APIS=(
    "sourcerepo.googleapis.com"        # Cloud Source Repositories
    "secretmanager.googleapis.com"     # Secret Manager
    "apigateway.googleapis.com"        # API Gateway
)

# Function to enable APIs
enable_apis() {
    local api_list=("$@")
    local api_string=""
    for api in "${api_list[@]}"; do
        api_string="$api_string --service=$api"
    done

    echo "📦 Enabling APIs: ${api_list[*]}"
    if gcloud services enable $api_string --quiet; then
        echo "✅ Successfully enabled ${#api_list[@]} API(s)"
    else
        echo "❌ Failed to enable some APIs"
        return 1
    fi
}

# Enable APIs in batches
echo "🔧 Enabling Core APIs..."
enable_apis "${CORE_APIS[@]}"

echo
echo "🗄️  Enabling Database APIs..."
enable_apis "${DATABASE_APIS[@]}"

echo
echo "🐳 Enabling Container & Serverless APIs..."
enable_apis "${CONTAINER_APIS[@]}"

echo
echo "🌐 Enabling Networking APIs..."
enable_apis "${NETWORKING_APIS[@]}"

echo
echo "📊 Enabling Observability APIs..."
enable_apis "${OBSERVABILITY_APIS[@]}"

echo
echo "🛠️  Enabling Development APIs..."
enable_apis "${DEVELOPMENT_APIS[@]}"

# Wait for APIs to be enabled
echo
echo "⏳ Waiting for APIs to be fully enabled..."
sleep 10

# Verify APIs are enabled
echo "🔍 Verifying API status..."
ENABLED_APIS=$(gcloud services list --enabled --format="value(config.name)" --project="$PROJECT_ID")

# Count enabled APIs
API_COUNT=$(echo "$ENABLED_APIS" | wc -l)

echo
echo "✅ API Enablement Complete!"
echo
echo "📊 Summary:"
echo "   Project: $PROJECT_ID"
echo "   APIs Enabled: $API_COUNT"
echo
echo "🔍 Key APIs now available:"
echo "   ✅ Compute Engine (compute.googleapis.com)"
echo "   ✅ Cloud Storage (storage-api.googleapis.com)"
echo "   ✅ Cloud SQL (sqladmin.googleapis.com)"
echo "   ✅ GKE (container.googleapis.com)"
echo "   ✅ Cloud Run (run.googleapis.com)"
echo "   ✅ Cloud Functions (cloudfunctions.googleapis.com)"
echo "   ✅ Firestore (firestore.googleapis.com)"
echo "   ✅ Cloud Build (cloudbuild.googleapis.com)"
echo "   ✅ Cloud Monitoring (monitoring.googleapis.com)"
echo "   ✅ Cloud Logging (logging.googleapis.com)"
echo
echo "📋 To check all enabled APIs:"
echo "   gcloud services list --enabled --project=$PROJECT_ID"
echo
echo "🧪 Test APIs with:"
echo "   gcloud compute zones list"
echo "   gsutil ls"
echo "   gcloud sql instances list"
