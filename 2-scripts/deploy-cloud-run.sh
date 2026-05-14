#!/bin/bash

# GCP Associate Cloud Engineer Lab
# Script: deploy-cloud-run.sh
# Purpose: Deploy a containerized application to Cloud Run
# Usage: ./deploy-cloud-run.sh [SERVICE_NAME] [IMAGE_URL] [REGION]

set -e  # Exit on any error

# Default values
SERVICE_NAME="${1:-hello-cloud-run}"
IMAGE_URL="${2:-gcr.io/cloudrun/hello}"
REGION="${3:-us-central1}"

# Configuration
PROJECT_ID="$(gcloud config get-value project)"

echo "🚀 Deploying to Cloud Run"
echo "📍 Project: $PROJECT_ID"
echo "🐳 Service: $SERVICE_NAME"
echo "🖼️  Image: $IMAGE_URL"
echo "🌍 Region: $REGION"
echo

# Validate inputs
if [ -z "$PROJECT_ID" ]; then
    echo "❌ Error: PROJECT_ID not set in gcloud config"
    echo "Run: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

# Enable Cloud Run API if not already enabled
echo "📦 Checking Cloud Run API..."
if ! gcloud services list --enabled --filter="config.name:run.googleapis.com" --format="value(config.name)" | grep -q "run.googleapis.com"; then
    echo "🔧 Enabling Cloud Run API..."
    gcloud services enable run.googleapis.com --quiet
fi

# Check if service already exists
if gcloud run services describe "$SERVICE_NAME" --region="$REGION" --project="$PROJECT_ID" &>/dev/null; then
    echo "⚠️  Service '$SERVICE_NAME' already exists"
    read -p "Do you want to update it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Deployment cancelled"
        exit 1
    fi
    UPDATE_MODE=true
else
    UPDATE_MODE=false
fi

# Deploy to Cloud Run
echo "🚀 Deploying service..."

if [ "$UPDATE_MODE" = true ]; then
    echo "📝 Updating existing service..."
    gcloud run deploy "$SERVICE_NAME" \
        --image="$IMAGE_URL" \
        --region="$REGION" \
        --allow-unauthenticated \
        --port=8080 \
        --memory=256Mi \
        --cpu=1 \
        --max-instances=10 \
        --timeout=300 \
        --concurrency=80 \
        --project="$PROJECT_ID" \
        --quiet
else
    echo "🏗️  Creating new service..."
    gcloud run deploy "$SERVICE_NAME" \
        --image="$IMAGE_URL" \
        --region="$REGION" \
        --allow-unauthenticated \
        --port=8080 \
        --memory=256Mi \
        --cpu=1 \
        --max-instances=10 \
        --timeout=300 \
        --concurrency=80 \
        --project="$PROJECT_ID" \
        --quiet
fi

# Get service URL
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" \
    --region="$REGION" \
    --project="$PROJECT_ID" \
    --format="value(status.url)")

echo
echo "✅ Cloud Run deployment successful!"
echo
echo "📊 Service Details:"
echo "   Name: $SERVICE_NAME"
echo "   Region: $REGION"
echo "   URL: $SERVICE_URL"
echo "   Image: $IMAGE_URL"
echo "   Memory: 256Mi"
echo "   CPU: 1"
echo "   Max Instances: 10"
echo "   Timeout: 300s"
echo "   Concurrency: 80"
echo
echo "🧪 Test the service:"
echo "   curl $SERVICE_URL"
echo "   Open $SERVICE_URL in your browser"
echo
echo "📋 Management Commands:"
echo "   Logs: gcloud logging read \"resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE_NAME\" --limit=10"
echo "   Update: gcloud run deploy $SERVICE_NAME --image=new-image --region=$REGION"
echo "   Delete: gcloud run services delete $SERVICE_NAME --region=$REGION"
echo
echo "🔧 Advanced Configuration:"
echo "   # Set environment variables"
echo "   gcloud run deploy $SERVICE_NAME --set-env-vars KEY1=value1,KEY2=value2 --region=$REGION"
echo
echo "   # Connect to Cloud SQL"
echo "   gcloud run deploy $SERVICE_NAME --add-cloudsql-instances=PROJECT_ID:REGION:INSTANCE_NAME --region=$REGION"
echo
echo "   # Mount secrets"
echo "   gcloud run deploy $SERVICE_NAME --set-secrets SECRET_NAME=secret:latest --region=$REGION"
echo
echo "   # Require authentication"
echo "   gcloud run deploy $SERVICE_NAME --no-allow-unauthenticated --region=$REGION"
