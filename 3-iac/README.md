# 3-iac/ - Infrastructure as Code with Terraform

This directory contains Terraform configurations for provisioning GCP infrastructure, demonstrating Infrastructure as Code (IaC) best practices for the Associate Cloud Engineer certification.

## 📁 Directory Structure

```
3-iac/
├── vpc-setup/           # VPC network, subnets, firewall rules
│   ├── main.tf         # Main configuration
│   ├── variables.tf    # Input variables
│   ├── outputs.tf      # Output values
│   └── terraform.tfvars # Variable values
└── gke-cluster/         # GKE cluster with node pools
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── terraform.tfvars
```

## 🚀 Quick Start

### Prerequisites
```bash
# Install Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Authenticate with GCP
gcloud auth application-default login
```

### Deploy VPC Infrastructure
```bash
cd 3-iac/vpc-setup
terraform init
terraform plan
terraform apply
```

### Deploy GKE Cluster
```bash
cd 3-iac/gke-cluster
terraform init
terraform plan
terraform apply
```

## 📚 What You'll Learn

### VPC Setup Module
- **Custom VPC Networks** - Private networking isolation
- **Subnets** - Regional IP address management
- **Firewall Rules** - Security policies for traffic control
- **Cloud NAT** - Outbound internet access for private instances
- **VPC Peering** - Connecting multiple VPC networks

### GKE Cluster Module
- **Kubernetes Clusters** - Container orchestration
- **Node Pools** - Compute resources for pods
- **Workload Identity** - Secure service account access
- **Network Policies** - Pod-to-pod communication control
- **Auto-scaling** - Dynamic resource management

## 🎯 Certification Benefits

- **ACE Exam Topics**: Infrastructure automation, networking, containers
- **Production Skills**: Version control, state management, modular design
- **Best Practices**: Security, cost optimization, reliability patterns

## 🛠️ Terraform Best Practices Demonstrated

- **Modular Architecture** - Reusable, maintainable code
- **Variable Management** - Flexible configuration
- **State Management** - Remote state with locking
- **Resource Dependencies** - Proper ordering and references
- **Output Values** - Exposing important information
- **Documentation** - Clear comments and descriptions

## 🔧 Customization

Edit `terraform.tfvars` files to customize:
- Project ID and region
- Network CIDR ranges
- Machine types and disk sizes
- Node pool configurations
- Security settings

## 🧹 Cleanup

```bash
# Destroy GKE cluster first
cd 3-iac/gke-cluster
terraform destroy

# Then destroy VPC
cd ../vpc-setup
terraform destroy
```

## 📋 Next Steps

After deploying infrastructure, you can:
1. Deploy applications from `4-apps/` directory
2. Use scripts from `2-scripts/` for additional configuration
3. Monitor resources with commands from `5-cheat-sheets/`

---

**Note**: Remember to enable required APIs and set billing before deploying!
