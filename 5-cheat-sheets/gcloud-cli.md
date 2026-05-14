# gcloud CLI Cheat Sheet

Comprehensive guide to Google Cloud SDK commands for the Associate Cloud Engineer certification.

## 🔧 Core Commands

### Authentication & Configuration
```bash
# Login and setup
gcloud auth login                                    # Interactive login
gcloud auth application-default login               # ADC for applications
gcloud auth list                                    # List active accounts
gcloud auth revoke user@example.com                 # Revoke account access

# Configuration
gcloud config set project PROJECT_ID                # Set default project
gcloud config set compute/region us-central1        # Set default region
gcloud config set compute/zone us-central1-a        # Set default zone
gcloud config list                                 # Show current config
gcloud config configurations list                  # List configurations
gcloud config configurations create dev            # Create named config
gcloud config configurations activate dev          # Switch configuration
```

### Project Management
```bash
# Project operations
gcloud projects list                               # List all projects
gcloud projects describe PROJECT_ID                # Project details
gcloud projects create PROJECT_ID --name="My Project" # Create project
gcloud projects delete PROJECT_ID                  # Delete project

# Billing
gcloud billing accounts list                       # List billing accounts
gcloud billing projects link PROJECT_ID --billing-account BILLING_ID
gcloud billing projects unlink PROJECT_ID          # Unlink billing
```

## ☁️ Compute Engine

### VM Instances
```bash
# Create instances
gcloud compute instances create INSTANCE_NAME \
  --machine-type e2-medium \
  --image-family ubuntu-2004-lts \
  --image-project ubuntu-os-cloud \
  --zone us-central1-a \
  --tags http-server,https-server

# List and describe
gcloud compute instances list                      # List all instances
gcloud compute instances describe INSTANCE_NAME   # Instance details
gcloud compute instances list --filter="status=RUNNING" # Filter running

# Instance operations
gcloud compute instances start INSTANCE_NAME      # Start instance
gcloud compute instances stop INSTANCE_NAME       # Stop instance
gcloud compute instances reset INSTANCE_NAME      # Reset instance
gcloud compute instances delete INSTANCE_NAME     # Delete instance

# SSH access
gcloud compute ssh INSTANCE_NAME --zone ZONE      # SSH to instance
gcloud compute scp local-file INSTANCE_NAME:~/remote-file # Copy files
```

### Instance Templates & Groups
```bash
# Instance templates
gcloud compute instance-templates create TEMPLATE_NAME \
  --machine-type e2-medium \
  --image-family ubuntu-2004-lts \
  --image-project ubuntu-os-cloud \
  --tags http-server

gcloud compute instance-templates list            # List templates
gcloud compute instance-templates describe TEMPLATE_NAME

# Managed instance groups
gcloud compute instance-groups managed create GROUP_NAME \
  --template TEMPLATE_NAME \
  --size 3 \
  --zone us-central1-a

gcloud compute instance-groups managed list       # List groups
gcloud compute instance-groups managed describe GROUP_NAME
gcloud compute instance-groups managed resize GROUP_NAME --size 5
gcloud compute instance-groups managed delete GROUP_NAME
```

### Disks & Images
```bash
# Disk operations
gcloud compute disks create DISK_NAME --size 100GB --zone ZONE
gcloud compute disks list --filter="zone:(ZONE)"
gcloud compute disks describe DISK_NAME --zone ZONE
gcloud compute disks delete DISK_NAME --zone ZONE

# Images
gcloud compute images list                        # List public images
gcloud compute images create IMAGE_NAME \
  --source-disk DISK_NAME \
  --source-disk-zone ZONE
gcloud compute images delete IMAGE_NAME
```

## 🚢 Kubernetes Engine (GKE)

### Cluster Operations
```bash
# Create clusters
gcloud container clusters create CLUSTER_NAME \
  --num-nodes 3 \
  --machine-type e2-medium \
  --zone us-central1-a

gcloud container clusters create CLUSTER_NAME \
  --num-nodes 3 \
  --machine-type e2-medium \
  --region us-central1 \
  --node-locations us-central1-a,us-central1-b,us-central1-c

# Cluster management
gcloud container clusters list                    # List clusters
gcloud container clusters describe CLUSTER_NAME  # Cluster details
gcloud container clusters get-credentials CLUSTER_NAME # Configure kubectl
gcloud container clusters resize CLUSTER_NAME --node-pool default-pool --num-nodes 5
gcloud container clusters delete CLUSTER_NAME    # Delete cluster

# Node pools
gcloud container node-pools create POOL_NAME \
  --cluster CLUSTER_NAME \
  --machine-type e2-standard-2 \
  --num-nodes 2

gcloud container node-pools list --cluster CLUSTER_NAME
gcloud container node-pools describe POOL_NAME --cluster CLUSTER_NAME
```

## 🗄️ Cloud Storage

### Bucket Operations
```bash
# Create and manage buckets
gsutil mb gs://BUCKET_NAME                     # Create bucket
gsutil ls                                      # List buckets
gsutil ls gs://BUCKET_NAME                     # List bucket contents
gsutil du -s gs://BUCKET_NAME                  # Bucket size
gsutil rm -r gs://BUCKET_NAME                  # Delete bucket

# Bucket configuration
gsutil versioning set on gs://BUCKET_NAME     # Enable versioning
gsutil versioning get gs://BUCKET_NAME        # Check versioning
gsutil lifecycle set lifecycle.json gs://BUCKET_NAME # Set lifecycle
gsutil iam ch allUsers:objectViewer gs://BUCKET_NAME # Public access
```

### File Operations
```bash
# Upload/download
gsutil cp local-file gs://BUCKET_NAME/         # Upload file
gsutil cp gs://BUCKET_NAME/file local-file    # Download file
gsutil cp -r local-dir gs://BUCKET_NAME/       # Upload directory
gsutil rsync -r local-dir gs://BUCKET_NAME/   # Sync directory

# File management
gsutil ls -l gs://BUCKET_NAME/file            # File details
gsutil mv gs://BUCKET_NAME/file gs://BUCKET_NAME/new-file # Move/rename
gsutil rm gs://BUCKET_NAME/file               # Delete file
gsutil rm -a gs://BUCKET_NAME/file            # Delete all versions
```

## 🔒 Identity & Access Management

### IAM Roles & Permissions
```bash
# Service accounts
gcloud iam service-accounts create SA_NAME \
  --description "Service account description" \
  --display-name "SA Display Name"

gcloud iam service-accounts list              # List service accounts
gcloud iam service-accounts describe SA_EMAIL # SA details
gcloud iam service-accounts delete SA_EMAIL  # Delete SA

# Service account keys
gcloud iam service-accounts keys create key.json --iam-account SA_EMAIL
gcloud iam service-accounts keys list --iam-account SA_EMAIL
gcloud iam service-accounts keys delete KEY_ID --iam-account SA_EMAIL

# IAM policies
gcloud projects get-iam-policy PROJECT_ID     # Get project IAM
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member user:USER_EMAIL \
  --role roles/editor

gcloud projects remove-iam-policy-binding PROJECT_ID \
  --member user:USER_EMAIL \
  --role roles/editor
```

## 🌐 Networking

### VPC Networks
```bash
# Network operations
gcloud compute networks create NETWORK_NAME --subnet-mode auto
gcloud compute networks create NETWORK_NAME --subnet-mode custom
gcloud compute networks list
gcloud compute networks describe NETWORK_NAME
gcloud compute networks delete NETWORK_NAME

# Subnets
gcloud compute networks subnets create SUBNET_NAME \
  --network NETWORK_NAME \
  --range 10.0.1.0/24 \
  --region us-central1

gcloud compute networks subnets list --network NETWORK_NAME
gcloud compute networks subnets describe SUBNET_NAME --region REGION
```

### Firewall Rules
```bash
# Firewall management
gcloud compute firewall-rules create RULE_NAME \
  --network NETWORK_NAME \
  --allow tcp:80,tcp:443 \
  --target-tags http-server \
  --source-ranges 0.0.0.0/0

gcloud compute firewall-rules list --filter="network:NETWORK_NAME"
gcloud compute firewall-rules describe RULE_NAME
gcloud compute firewall-rules update RULE_NAME --allow tcp:22
gcloud compute firewall-rules delete RULE_NAME
```

## 🚀 Cloud Run

### Service Deployment
```bash
# Deploy from source
gcloud run deploy SERVICE_NAME \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated

# Deploy from container
gcloud run deploy SERVICE_NAME \
  --image gcr.io/PROJECT_ID/IMAGE_NAME \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 8080 \
  --memory 512Mi \
  --cpu 1

# Service management
gcloud run services list --region us-central1
gcloud run services describe SERVICE_NAME --region us-central1
gcloud run services delete SERVICE_NAME --region us-central1
```

## 📊 Monitoring & Logging

### Cloud Logging
```bash
# Log operations
gcloud logging logs list                        # List log types
gcloud logging read "resource.type=gce_instance" --limit 10
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=SERVICE_NAME"

# Export logs
gcloud logging sinks create SINK_NAME \
  storage.googleapis.com/projects/PROJECT_ID/buckets/BUCKET_NAME \
  --log-filter "resource.type=gce_instance"
```

### Cloud Monitoring
```bash
# Metrics and alerts
gcloud monitoring metrics list                  # List metrics
gcloud monitoring metrics descriptors describe compute.googleapis.com/instance/cpu/utilization

# Uptime checks
gcloud monitoring uptime-check-configs list
gcloud monitoring uptime-check-configs create CHECK_NAME \
  --resource-type uptime-url \
  --resource-labels host=example.com
```

## 🔧 Utility Commands

### Help & Information
```bash
gcloud help                                    # General help
gcloud COMMAND --help                          # Command-specific help
gcloud info                                    # SDK information
gcloud version                                 # Version information

# List available components
gcloud components list
gcloud components install COMPONENT_NAME
gcloud components update
```

### Output Formatting
```bash
# Format options
gcloud compute instances list --format="table(name,zone,status)"
gcloud compute instances list --format="json"
gcloud compute instances list --format="yaml"
gcloud compute instances list --format="csv(name,zone.machineType)"

# Filtering
gcloud compute instances list --filter="zone:us-central1-a AND status:RUNNING"
gcloud compute instances list --filter="name~'web-*'"
```

### Batch Operations
```bash
# Execute multiple commands
gcloud compute instances start INSTANCE1 INSTANCE2 INSTANCE3
gcloud compute disks delete DISK1 DISK2 --zone ZONE

# Use --quiet to skip prompts
gcloud compute instances delete INSTANCE_NAME --quiet
```

## 🚨 Troubleshooting

### Common Issues
```bash
# Check service account permissions
gcloud auth list
gcloud config get-value account

# Check project settings
gcloud config get-value project
gcloud config get-value compute/region
gcloud config get-value compute/zone

# Check API enablement
gcloud services list --enabled
gcloud services enable SERVICE_NAME

# Check quotas
gcloud compute regions describe us-central1
```

### Debug Commands
```bash
# Instance serial console
gcloud compute instances get-serial-port-output INSTANCE_NAME --zone ZONE

# SSH debugging
gcloud compute ssh INSTANCE_NAME --zone ZONE --troubleshoot

# Network debugging
gcloud compute instances describe INSTANCE_NAME --zone ZONE --format="get(networkInterfaces[0].accessConfigs[0].natIP)"
```

---

**Pro Tips:**
- Use `--dry-run` to preview changes
- Use `--async` for long-running operations
- Use `--verbosity=debug` for detailed output
- Use tab completion for faster command entry
