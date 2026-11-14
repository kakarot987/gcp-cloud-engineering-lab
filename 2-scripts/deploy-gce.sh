#!/bin/bash

# GCP Associate Cloud Engineer Lab
# Script: deploy-gce.sh
# Purpose: Deploy a Compute Engine instance with custom configuration
# Usage: ./deploy-gce.sh [INSTANCE_NAME] [ZONE] [MACHINE_TYPE] [SUBNET]

set -e  # Exit on any error

# Default values
INSTANCE_NAME="${1:-web-server-01}"
ZONE="${2:-us-central1-a}"
MACHINE_TYPE="${3:-n1-standard-1}"
SUBNET="${4:-custom-vpc-web}"

# Configuration
PROJECT_ID="$(gcloud config get-value project)"
VPC_NAME="custom-vpc"
IMAGE_FAMILY="debian-11"
IMAGE_PROJECT="debian-cloud"
BOOT_DISK_SIZE="20GB"
TAGS="web-server"
SERVICE_ACCOUNT=""

echo "WARNING: This script creates a billable VM and disk. Remove both after the lab."
echo " Deploying GCE Instance: $INSTANCE_NAME"
echo " Project: $PROJECT_ID"
echo " Zone: $ZONE"
echo " Machine Type: $MACHINE_TYPE"
echo "️  Subnet: $SUBNET"
echo

# Validate inputs
if [ -z "$PROJECT_ID" ]; then
    echo "❌ Error: PROJECT_ID not set in gcloud config"
    echo "Run: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

# Check if VPC and subnet exist
echo " Checking VPC and subnet..."
if ! gcloud compute networks describe "$VPC_NAME" --project="$PROJECT_ID" &>/dev/null; then
    echo "❌ Error: VPC '$VPC_NAME' does not exist"
    echo "Run: ./create-vpc.sh first"
    exit 1
fi

if ! gcloud compute networks subnets describe "$SUBNET" --region="${ZONE%-*}" --project="$PROJECT_ID" &>/dev/null; then
    echo "❌ Error: Subnet '$SUBNET' does not exist"
    echo "Available subnets:"
    gcloud compute networks subnets list --network="$VPC_NAME" --project="$PROJECT_ID" --format="value(name)"
    exit 1
fi

# Create startup script
STARTUP_SCRIPT=$(cat << 'EOF'
#!/bin/bash
# Update system
apt-get update
apt-get upgrade -y

# Install essential packages
apt-get install -y \
    curl \
    wget \
    vim \
    htop \
    git \
    python3 \
    python3-pip \
    nginx

# Configure nginx
cat > /etc/nginx/sites-available/default << 'NGINX_CONF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }

    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
NGINX_CONF

# Fetch only selected non-secret metadata on the INSTANCE, not from a visitor's browser.
metadata() {
    curl --fail --silent --show-error --max-time 5 \
        -H 'Metadata-Flavor: Google' \
        "http://metadata.google.internal/computeMetadata/v1/$1" || echo unavailable
}
export LAB_HOSTNAME="$(metadata instance/hostname)"
export LAB_INTERNAL_IP="$(metadata instance/network-interfaces/0/ip)"
export LAB_ZONE="$(metadata instance/zone)"
export LAB_PROJECT="$(metadata project/project-id)"

# Render a static HTML page; html.escape prevents metadata values injecting markup.
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8"><title>GCP ACE Lab</title></head>
<body>
<h1>GCP Associate Cloud Engineer Lab</h1>
<p>Hostname: __HOSTNAME__</p>
<p>Internal IP: __INTERNAL_IP__</p>
<p>Zone: __ZONE__</p>
<p>Project: __PROJECT__</p>
<p>Generated (UTC): __TIMESTAMP__</p>
</body></html>
HTML
python3 - << 'PYTHON'
import html
import os
from datetime import datetime, timezone
from pathlib import Path

page = Path("/var/www/html/index.html")
content = page.read_text()
values = {
    "__HOSTNAME__": os.environ.get("LAB_HOSTNAME", "unavailable"),
    "__INTERNAL_IP__": os.environ.get("LAB_INTERNAL_IP", "unavailable"),
    "__ZONE__": os.environ.get("LAB_ZONE", "unavailable").rsplit("/", 1)[-1],
    "__PROJECT__": os.environ.get("LAB_PROJECT", "unavailable"),
    "__TIMESTAMP__": datetime.now(timezone.utc).isoformat(),
}
for token, value in values.items():
    content = content.replace(token, html.escape(value, quote=True))
page.write_text(content)
PYTHON

# Start nginx
systemctl enable nginx
systemctl start nginx

# Configure logging
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
bash add-google-cloud-ops-agent-repo.sh --also-install

# Create log file
echo "$(date): Instance $HOSTNAME started successfully" >> /var/log/gcp-lab.log
EOF
)

# Create the instance
echo "️  Creating Compute Engine instance..."
gcloud compute instances create "$INSTANCE_NAME" \
    --zone="$ZONE" \
    --machine-type="$MACHINE_TYPE" \
    --subnet="$SUBNET" \
    --network-tier=PREMIUM \
    --maintenance-policy=MIGRATE \
    --image-family="$IMAGE_FAMILY" \
    --image-project="$IMAGE_PROJECT" \
    --boot-disk-size="$BOOT_DISK_SIZE" \
    --boot-disk-type=pd-standard \
    --boot-disk-device-name="${INSTANCE_NAME}-boot" \
    --tags="$TAGS" \
    --metadata=startup-script="$STARTUP_SCRIPT" \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --project="$PROJECT_ID"

# Wait for instance to be ready
echo "⏳ Waiting for instance to be ready..."
sleep 10

# Get instance information
EXTERNAL_IP=$(gcloud compute instances describe "$INSTANCE_NAME" \
    --zone="$ZONE" \
    --format="get(networkInterfaces[0].accessConfigs[0].natIP)" \
    --project="$PROJECT_ID")

INTERNAL_IP=$(gcloud compute instances describe "$INSTANCE_NAME" \
    --zone="$ZONE" \
    --format="get(networkInterfaces[0].networkIP)" \
    --project="$PROJECT_ID")

echo
echo "✅ Instance '$INSTANCE_NAME' deployed successfully!"
echo
echo " Instance Details:"
echo "   Name: $INSTANCE_NAME"
echo "   Zone: $ZONE"
echo "   Machine Type: $MACHINE_TYPE"
echo "   External IP: $EXTERNAL_IP"
echo "   Internal IP: $INTERNAL_IP"
echo "   Web URL: http://$EXTERNAL_IP"
echo "   Health Check: http://$EXTERNAL_IP/health"
echo
echo " Management Commands:"
echo "   SSH: gcloud compute ssh $INSTANCE_NAME --zone=$ZONE"
echo "   Logs: gcloud compute instances get-serial-port-output $INSTANCE_NAME --zone=$ZONE"
echo "   Stop: gcloud compute instances stop $INSTANCE_NAME --zone=$ZONE"
echo "   Delete: gcloud compute instances delete $INSTANCE_NAME --zone=$ZONE"
echo
echo " Test the web server:"
echo "   curl http://$EXTERNAL_IP"
echo "   Open http://$EXTERNAL_IP in your browser"