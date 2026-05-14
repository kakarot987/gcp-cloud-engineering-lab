# GCP Scripts Directory

This directory contains shell scripts for common GCP Associate Cloud Engineer tasks. Each script is designed to be educational and production-ready with proper error handling and documentation.

## 📋 Available Scripts

### 1. `create-vpc.sh`
**Purpose:** Create a custom VPC network with subnets and firewall rules
```bash
./create-vpc.sh [PROJECT_ID] [REGION] [VPC_NAME]
```
- Creates custom VPC with 3 subnets (web, app, db)
- Sets up comprehensive firewall rules
- Includes internal traffic and database access rules

### 2. `deploy-gce.sh`
**Purpose:** Deploy a Compute Engine instance with web server
```bash
./deploy-gce.sh [INSTANCE_NAME] [ZONE] [MACHINE_TYPE] [SUBNET]
```
- Deploys GCE instance with nginx web server
- Includes startup script with metadata service integration
- Creates sample web page showing instance information

### 3. `enable-apis.sh`
**Purpose:** Enable commonly used GCP APIs
```bash
./enable-apis.sh [PROJECT_ID]
```
- Enables 30+ GCP APIs in organized batches
- Covers Compute, Storage, Database, Container, and Monitoring services
- Verifies API enablement status

### 4. `setup-iam.sh`
**Purpose:** Create service accounts and set up IAM permissions
```bash
./setup-iam.sh [PROJECT_ID]
```
- Creates 4 service accounts (app-backend, data-pipeline, monitoring, ci-cd)
- Grants appropriate IAM roles for each use case
- Generates service account keys (with security warnings)

### 5. `create-bucket.sh`
**Purpose:** Create Cloud Storage bucket with proper configuration
```bash
./create-bucket.sh [BUCKET_NAME] [LOCATION] [STORAGE_CLASS]
```
- Creates bucket with lifecycle policies
- Sets up versioning and uniform access
- Creates sample folder structure and files

### 6. `deploy-cloud-run.sh`
**Purpose:** Deploy containerized application to Cloud Run
```bash
./deploy-cloud-run.sh [SERVICE_NAME] [IMAGE_URL] [REGION]
```
- Deploys to Cloud Run with optimized settings
- Supports both new deployments and updates
- Includes configuration examples for environment variables

### 7. `setup-gke.sh`
**Purpose:** Create Google Kubernetes Engine cluster
```bash
./setup-gke.sh [CLUSTER_NAME] [ZONE] [NODE_COUNT]
```
- Creates GKE cluster with autoscaling
- Sets up VPC and subnet with secondary ranges
- Deploys sample application with LoadBalancer service

### 8. `backup-sql.sh`
**Purpose:** Create backup of Cloud SQL instance
```bash
./backup-sql.sh [INSTANCE_NAME] [BACKUP_DESCRIPTION]
```
- Creates on-demand backup of Cloud SQL instance
- Monitors backup progress
- Provides restore examples

## 🚀 Quick Start

1. **Set your project:**
   ```bash
   gcloud config set project YOUR_PROJECT_ID
   ```

2. **Make scripts executable:**
   ```bash
   chmod +x *.sh
   ```

3. **Run scripts in order:**
   ```bash
   ./enable-apis.sh
   ./create-vpc.sh
   ./setup-iam.sh
   ./create-bucket.sh
   ./deploy-gce.sh
   ./deploy-cloud-run.sh
   ./setup-gke.sh
   ```

## 📚 Script Features

### ✅ Error Handling
- Input validation
- Resource existence checks
- Graceful failure with helpful messages

### ✅ Documentation
- Comprehensive comments
- Usage examples
- Management commands reference

### ✅ Best Practices
- Security considerations
- Cost optimization
- Production-ready configurations

### ✅ Educational
- Real-world scenarios
- Interview-relevant examples
- GCP ACE exam preparation

## 🔧 Prerequisites

- Google Cloud SDK installed and configured
- Appropriate permissions in GCP project
- Bash shell environment

## 📝 Usage Tips

1. **Always check script output** for important information
2. **Review IAM permissions** before running in production
3. **Monitor costs** - some resources incur charges
4. **Clean up resources** when done experimenting

## 🧹 Cleanup Scripts

While not included, here are cleanup commands for each script:

```bash
# VPC cleanup
gcloud compute firewall-rules delete $(gcloud compute firewall-rules list --filter="network:custom-vpc" --format="value(name)")
gcloud compute networks subnets delete custom-vpc-web --region=us-central1
gcloud compute networks delete custom-vpc

# GCE cleanup
gcloud compute instances delete INSTANCE_NAME --zone=ZONE

# Bucket cleanup
gsutil rm -r gs://BUCKET_NAME/

# Cloud Run cleanup
gcloud run services delete SERVICE_NAME --region=REGION

# GKE cleanup
kubectl delete namespace gcp-ace-lab
gcloud container clusters delete CLUSTER_NAME --zone=ZONE

# IAM cleanup
gcloud iam service-accounts delete SERVICE_ACCOUNT_EMAIL
```

## 🎯 Learning Objectives

These scripts demonstrate:
- Infrastructure as Code principles
- GCP resource management
- Security best practices
- Cost optimization
- Automation techniques
- Troubleshooting skills

Perfect for GCP Associate Cloud Engineer certification preparation!
