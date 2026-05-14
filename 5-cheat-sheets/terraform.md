# Terraform Cheat Sheet

Essential Terraform commands for infrastructure as code and GCP deployments.

## 🔧 Terraform Basics

### Installation & Setup
```bash
# Install Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Verify installation
terraform version
terraform -help
```

### Workspace Initialization
```bash
# Initialize Terraform
terraform init                                    # Initialize directory
terraform init -upgrade                           # Upgrade providers
terraform init -reconfigure                       # Reconfigure backend

# Validate configuration
terraform validate                                # Validate syntax
terraform fmt                                     # Format code
terraform fmt -check                              # Check formatting
```

### Planning & Applying
```bash
# Plan changes
terraform plan                                    # Show execution plan
terraform plan -out=tfplan                        # Save plan to file
terraform plan -var="region=us-central1"           # With variables
terraform plan -target=google_compute_instance.vm # Target specific resource

# Apply changes
terraform apply                                   # Apply changes (interactive)
terraform apply tfplan                            # Apply saved plan
terraform apply -auto-approve                     # Non-interactive apply
terraform apply -var-file=prod.tfvars             # With variable file
```

## 📁 State Management

### State Operations
```bash
# State inspection
terraform show                                    # Show state
terraform show -json                              # JSON format
terraform state list                              # List resources
terraform state show google_compute_instance.vm   # Show specific resource

# State manipulation
terraform state mv old_resource new_resource      # Move resource
terraform state rm google_compute_instance.vm     # Remove from state
terraform state pull                              # Download state
terraform state push                              # Upload state
```

### State Backends
```bash
# Local backend (default)
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# GCS backend
terraform {
  backend "gcs" {
    bucket = "my-terraform-state"
    prefix = "terraform/state"
  }
}

# Migrate backend
terraform init -migrate-state                      # Migrate existing state
terraform init -force-copy                        # Force migration
```

## 📝 Configuration Files

### Basic Structure
```hcl
# main.tf
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_instance" "vm" {
  name         = "my-vm"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }
}
```

### Variables & Outputs
```hcl
# variables.tf
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1
  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 5
    error_message = "Instance count must be between 1 and 5."
  }
}

# outputs.tf
output "instance_names" {
  description = "Names of created instances"
  value       = google_compute_instance.vm[*].name
}

output "instance_ips" {
  description = "External IPs of instances"
  value       = google_compute_instance.vm[*].network_interface[0].access_config[0].nat_ip
}
```

### Variable Files
```hcl
# terraform.tfvars
project_id     = "my-gcp-project"
region         = "us-central1"
instance_count = 2

# prod.tfvars
project_id     = "my-prod-project"
region         = "us-east1"
instance_count = 3
```

## 🔄 Resource Management

### Resource Lifecycle
```bash
# Create resources
terraform apply                                  # Create all resources
terraform apply -target=google_compute_instance.vm # Create specific resource

# Update resources
terraform plan                                   # Show updates needed
terraform apply                                  # Apply updates

# Destroy resources
terraform destroy                                # Destroy all resources
terraform destroy -target=google_compute_instance.vm # Destroy specific resource
terraform destroy -auto-approve                  # Non-interactive destroy
```

### Resource Dependencies
```bash
# Implicit dependencies
resource "google_compute_instance" "vm" {
  name         = "my-vm"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc.name  # Implicit dependency
  }
}

# Explicit dependencies
resource "google_compute_instance" "vm" {
  depends_on = [google_compute_network.vpc]    # Explicit dependency
  # ... rest of config
}
```

## 📊 Data Sources

### Using Data Sources
```hcl
# Data source example
data "google_compute_image" "debian" {
  family  = "debian-11"
  project = "debian-cloud"
}

data "google_client_config" "current" {}

# Use in resources
resource "google_compute_instance" "vm" {
  name         = "my-vm"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian.self_link
    }
  }
}
```

### Common Data Sources
```hcl
# GCP data sources
data "google_project" "current" {}

data "google_compute_zones" "available" {
  region = var.region
}

data "google_container_cluster" "my_cluster" {
  name     = "my-cluster"
  location = var.region
}

data "google_storage_bucket" "my_bucket" {
  name = "my-bucket"
}
```

## 🔀 Modules

### Using Modules
```hcl
# main.tf
module "vpc" {
  source = "./modules/vpc"

  project_id = var.project_id
  region     = var.region
  vpc_name   = "my-vpc"
}

module "gke" {
  source = "./modules/gke"

  project_id    = var.project_id
  region        = var.region
  cluster_name  = "my-cluster"
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.subnet_id
}
```

### Module Structure
```hcl
# modules/vpc/main.tf
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.vpc_name}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
}

# modules/vpc/variables.tf
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR range for subnet"
  type        = string
  default     = "10.0.0.0/24"
}

# modules/vpc/outputs.tf
output "vpc_id" {
  description = "ID of the created VPC"
  value       = google_compute_network.vpc.id
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = google_compute_subnetwork.subnet.id
}
```

## 🔧 Advanced Features

### Workspaces
```bash
# Workspace management
terraform workspace list                          # List workspaces
terraform workspace select dev                    # Select workspace
terraform workspace new prod                      # Create workspace
terraform workspace delete prod                   # Delete workspace

# Workspace-specific variables
# dev.tfvars, prod.tfvars, etc.
```

### Remote State
```hcl
# Remote state configuration
terraform {
  backend "gcs" {
    bucket = "my-terraform-state"
    prefix = "terraform/state"
  }
}

# Lock state (GCS does this automatically)
terraform force-unlock LOCK_ID                    # Force unlock state
```

### Provisioners
```hcl
# Local-exec provisioner
resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "echo 'Hello World'"
  }
}

# Remote-exec provisioner
resource "null_resource" "remote" {
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
    }
  }
}
```

## 🚨 Troubleshooting

### Common Issues
```bash
# Syntax errors
terraform validate                               # Validate configuration
terraform fmt                                    # Format code

# State issues
terraform state list                             # Check state
terraform state show RESOURCE                    # Inspect resource
terraform refresh                                # Refresh state

# Provider issues
terraform init -upgrade                          # Upgrade providers
terraform providers                              # List providers
```

### Debug Commands
```bash
# Debug mode
export TF_LOG=DEBUG
terraform plan

# Verbose output
terraform plan -verbose
terraform apply -verbose

# Graph visualization
terraform graph | dot -Tsvg > graph.svg          # Generate dependency graph
terraform graph -type=plan | dot -Tsvg > plan.svg # Plan graph
```

## 📋 Best Practices

### Code Organization
```bash
# Recommended structure
.
├── main.tf              # Main resources
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── terraform.tfvars     # Variable values
├── versions.tf          # Version constraints
├── provider.tf          # Provider configuration
├── backend.tf           # Backend configuration
└── modules/             # Reusable modules
    ├── vpc/
    ├── gke/
    └── iam/
```

### Version Constraints
```hcl
# versions.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}
```

### Naming Conventions
```hcl
# Resource naming
resource "google_compute_instance" "web_server" {
  name = "web-server-${var.environment}-${random_id.suffix.hex}"
}

resource "google_storage_bucket" "data_bucket" {
  name = "${var.project_id}-data-${var.environment}"
}

# Variable naming
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}
```

## 📊 Import & Migration

### Importing Resources
```bash
# Import existing resources
terraform import google_compute_instance.vm projects/PROJECT_ID/zones/ZONE/instances/INSTANCE_NAME
terraform import google_storage_bucket.bucket BUCKET_NAME
terraform import google_compute_network.vpc projects/PROJECT_ID/global/networks/VPC_NAME

# Generate config from state
terraform show -json | jq '.values.root_module.resources[] | select(.type == "google_compute_instance")'
```

### Migration Strategies
```bash
# Move resources between modules
terraform state mv module.old.vpc module.new.vpc

# Update resource addresses
terraform state mv google_compute_instance.old google_compute_instance.new

# Remove resources from state
terraform state rm google_compute_instance.vm
```

---

**Pro Tips:**
- Always run `terraform plan` before `apply`
- Use `terraform fmt` to maintain consistent formatting
- Store state remotely for team collaboration
- Use modules for reusable infrastructure
- Validate configurations with `terraform validate`
- Use workspaces for environment separation
