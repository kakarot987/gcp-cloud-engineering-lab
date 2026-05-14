# GKE Cluster Module - terraform.tfvars
# Default variable values - customize for your environment

# Required: Set your GCP project ID (must match vpc-setup)
project_id = "your-project-id-here"

# Optional: Customize region (must match vpc-setup)
region = "us-central1"

# Optional: Reference existing VPC (must match vpc-setup)
vpc_name = "ace-learning-vpc"

# Optional: Customize cluster name
cluster_name = "ace-learning-cluster"

# Optional: GKE master CIDR (private cluster)
master_cidr = "172.16.0.0/28"

# Optional: Authorized networks for master access (restrict in production)
authorized_networks = ["0.0.0.0/0"]

# Standard Node Pool Configuration
standard_node_count   = 2
standard_machine_type = "e2-medium"
standard_min_nodes    = 1
standard_max_nodes    = 5

# Spot Node Pool Configuration (cost-effective)
spot_node_count   = 1
spot_machine_type = "e2-medium"
spot_min_nodes    = 0
spot_max_nodes    = 3

# Common Node Configuration
node_disk_size = 50
