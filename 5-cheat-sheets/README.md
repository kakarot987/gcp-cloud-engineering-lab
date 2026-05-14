# 5-cheat-sheets/ - GCP CLI Quick Reference

This directory contains comprehensive cheat sheets for Google Cloud Platform command-line tools, designed as quick reference guides for the Associate Cloud Engineer certification. Each cheat sheet focuses on essential commands you'll need for exam scenarios and real-world GCP administration.

## 📁 Cheat Sheet Collection

| File | Description | Use Case |
|------|-------------|----------|
| `gcloud-cli.md` | Core gcloud commands | Project setup, authentication, deployments |
| `gsutil.md` | Cloud Storage operations | Bucket management, file transfers |
| `kubectl.md` | Kubernetes operations | Pod management, deployments, debugging |
| `bq.md` | BigQuery operations | Data queries, dataset management |
| `docker.md` | Container operations | Image building, registry management |
| `terraform.md` | Infrastructure as Code | Resource provisioning, state management |
| `monitoring.md` | Observability commands | Logs, metrics, monitoring |
| `iam.md` | Identity management | Service accounts, roles, permissions |

## 🎯 How to Use These Cheat Sheets

### For Exam Preparation
- **Quick Reference**: Scan for command syntax during practice exams
- **Command Patterns**: Learn common parameter combinations
- **Error Solutions**: Find troubleshooting commands for common issues

### For Real Projects
- **Rapid Deployment**: Copy-paste commands for common tasks
- **Troubleshooting**: Quick access to diagnostic commands
- **Automation**: Build scripts using these patterns

## 📚 Command Categories

### 🔧 Core GCP Operations
- **Project Management**: Create, configure, and manage GCP projects
- **Authentication**: Login, service accounts, access tokens
- **Configuration**: Set regions, zones, and default settings

### ☁️ Compute Resources
- **Compute Engine**: VM creation, management, and monitoring
- **Kubernetes Engine**: Cluster operations and pod management
- **Cloud Run**: Serverless container deployment

### 🗄️ Storage & Databases
- **Cloud Storage**: Bucket operations and file management
- **Cloud SQL**: Database instance management
- **BigQuery**: Data warehouse operations

### 🔒 Security & Identity
- **IAM**: Role assignment and permission management
- **Service Accounts**: Creation and key management
- **Network Security**: Firewall rules and VPC configuration

### 📊 Monitoring & Logging
- **Cloud Logging**: Log filtering and export
- **Cloud Monitoring**: Metrics and alerting
- **Error Reporting**: Application error tracking

## 🚀 Quick Start Commands

### Initial Setup
```bash
# Authenticate and set project
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a
```

### Enable Common APIs
```bash
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable storage-api.googleapis.com
```

### Create Basic Resources
```bash
# VPC Network
gcloud compute networks create my-network --subnet-mode=auto

# Cloud Storage Bucket
gsutil mb gs://my-bucket/

# GKE Cluster
gcloud container clusters create my-cluster --num-nodes=3
```

## 🎓 Certification Tips

### ACE Exam Focus Areas
- **Command Syntax**: Know exact parameter names and formats
- **Resource Hierarchy**: Projects, folders, organizations
- **IAM Roles**: Basic, predefined, and custom roles
- **Networking**: VPCs, subnets, firewall rules
- **Storage Classes**: Regional, multi-regional, nearline, coldline

### Common Exam Scenarios
- **VM Troubleshooting**: SSH access, logs, serial console
- **Network Issues**: Connectivity, firewall rules, routes
- **Storage Problems**: Permissions, lifecycle, versioning
- **Kubernetes**: Pod status, logs, scaling

### Time-Saving Tips
- Use `--help` for detailed command information
- Leverage tab completion for commands and parameters
- Use `--format` for custom output formatting
- Combine commands with pipes for complex operations

## 🔍 Finding Commands Quickly

### Search by Task
- **Need to create a VM?** → Check `gcloud-cli.md` under Compute Engine
- **Storage bucket issues?** → See `gsutil.md` for bucket operations
- **Pod not starting?** → Look at `kubectl.md` for debugging commands
- **Permission denied?** → Check `iam.md` for role assignments

### Search by Error
- **"Permission denied"** → IAM role or service account issues
- **"Resource not found"** → Check project ID, region, or resource name
- **"Quota exceeded"** → Review resource limits and quotas
- **"Network timeout"** → Check firewall rules and connectivity

## 📋 Practice Exercises

Use these cheat sheets to complete common GCP tasks:

1. **Project Setup**: Create project, enable APIs, set IAM roles
2. **VM Deployment**: Launch VM, configure firewall, SSH access
3. **Storage Solution**: Create bucket, upload files, set permissions
4. **Container App**: Build image, push to GCR, deploy to Cloud Run
5. **Kubernetes**: Create cluster, deploy app, expose service
6. **Monitoring**: Set up logging, create alerts, view metrics

## 🧹 Cleanup Commands

Always clean up resources after testing:

```bash
# Delete VM instance
gcloud compute instances delete my-vm --zone=us-central1-a

# Delete GKE cluster
gcloud container clusters delete my-cluster --region=us-central1

# Delete storage bucket
gsutil rm -r gs://my-bucket/

# Delete project (CAUTION!)
gcloud projects delete YOUR_PROJECT_ID
```

## 📚 Additional Resources

- [GCP Documentation](https://cloud.google.com/docs)
- [gcloud Command Reference](https://cloud.google.com/sdk/gcloud/reference)
- [gsutil Command Reference](https://cloud.google.com/storage/docs/gsutil)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

---

**Remember**: These cheat sheets are for learning and reference. In production environments, always follow your organization's security policies and best practices.
