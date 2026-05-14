# VPC Setup Module - terraform.tfvars
# Default variable values - customize for your environment

# Required: Set your GCP project ID
project_id = "your-project-id-here"

# Optional: Customize region (default: us-central1)
region = "us-central1"

# Optional: Customize VPC name (default: ace-learning-vpc)
vpc_name = "ace-learning-vpc"

# Optional: Customize subnet CIDRs
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"

# Optional: GKE secondary ranges (don't change unless you know what you're doing)
pods_secondary_cidr     = "10.1.0.0/16"
services_secondary_cidr = "10.2.0.0/20"

pods_private_secondary_cidr     = "10.3.0.0/16"
services_private_secondary_cidr = "10.4.0.0/20"
