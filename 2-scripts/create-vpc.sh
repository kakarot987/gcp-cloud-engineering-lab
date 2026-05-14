#!/bin/bash

# GCP Associate Cloud Engineer Lab
# Script: create-vpc.sh
# Purpose: Create a custom VPC network with subnets and firewall rules
# Usage: ./create-vpc.sh [PROJECT_ID] [REGION] [VPC_NAME]

set -e  # Exit on any error

# Default values
PROJECT_ID="${1:-$(gcloud config get-value project)}"
REGION="${2:-us-central1}"
VPC_NAME="${3:-custom-vpc}"

echo " Creating VPC Network: $VPC_NAME"
echo " Project: $PROJECT_ID"
echo " Region: $REGION"
echo

# Validate inputs
if [ -z "$PROJECT_ID" ]; then
    echo "❌ Error: PROJECT_ID not provided and not set in gcloud config"
    echo "Usage: $0 [PROJECT_ID] [REGION] [VPC_NAME]"
    exit 1
fi

# Set project
echo " Setting project to: $PROJECT_ID"
gcloud config set project "$PROJECT_ID"

# Enable required APIs
echo " Enabling required APIs..."
gcloud services enable compute.googleapis.com --quiet

# Create VPC network
echo "️  Creating VPC network: $VPC_NAME"
gcloud compute networks create "$VPC_NAME" \
    --subnet-mode=custom \
    --bgp-routing-mode=regional \
    --description="Custom VPC for GCP ACE Lab"

# Create subnets
echo "️  Creating subnets..."

# Web subnet
gcloud compute networks subnets create "${VPC_NAME}-web" \
    --network="$VPC_NAME" \
    --region="$REGION" \
    --range=10.0.1.0/24 \
    --description="Web tier subnet"

# App subnet
gcloud compute networks subnets create "${VPC_NAME}-app" \
    --network="$VPC_NAME" \
    --region="$REGION" \
    --range=10.0.2.0/24 \
    --description="Application tier subnet"

# DB subnet
gcloud compute networks subnets create "${VPC_NAME}-db" \
    --network="$VPC_NAME" \
    --region="$REGION" \
    --range=10.0.3.0/24 \
    --description="Database tier subnet"

# Create firewall rules
echo " Creating firewall rules..."

# Allow SSH from anywhere (restrict in production!)
gcloud compute firewall-rules create "${VPC_NAME}-allow-ssh" \
    --network="$VPC_NAME" \
    --allow=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --description="Allow SSH access"

# Allow HTTP/HTTPS from anywhere
gcloud compute firewall-rules create "${VPC_NAME}-allow-web" \
    --network="$VPC_NAME" \
    --allow=tcp:80,tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=web-server \
    --description="Allow web traffic to tagged instances"

# Allow internal traffic between subnets
gcloud compute firewall-rules create "${VPC_NAME}-allow-internal" \
    --network="$VPC_NAME" \
    --allow=tcp:0-65535,udp:0-65535,icmp \
    --source-ranges=10.0.0.0/16 \
    --description="Allow all internal traffic"

# Allow database access from app tier
gcloud compute firewall-rules create "${VPC_NAME}-allow-db" \
    --network="$VPC_NAME" \
    --allow=tcp:3306,tcp:5432 \
    --source-tags=app-server \
    --target-tags=db-server \
    --description="Allow database access from app servers"

echo
echo "✅ VPC Network '$VPC_NAME' created successfully!"
echo
echo " Summary:"
echo "   VPC: $VPC_NAME (10.0.0.0/16)"
echo "   Web Subnet: ${VPC_NAME}-web (10.0.1.0/24)"
echo "   App Subnet: ${VPC_NAME}-app (10.0.2.0/24)"
echo "   DB Subnet: ${VPC_NAME}-db (10.0.3.0/24)"
echo
echo " To verify:"
echo "   gcloud compute networks describe $VPC_NAME"
echo "   gcloud compute networks subnets list --network=$VPC_NAME"
echo "   gcloud compute firewall-rules list --filter=\"network:$VPC_NAME\""