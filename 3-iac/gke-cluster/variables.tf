# GKE Cluster Module - variables.tf
# Input variables for GKE cluster configuration

variable "project_id" {
  description = "GCP Project ID where GKE cluster will be created"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.project_id))
    error_message = "Project ID must be lowercase, start with letter, contain only letters, numbers, and hyphens."
  }
}

variable "region" {
  description = "GCP region for GKE cluster"
  type        = string
  default     = "us-central1"
  validation {
    condition = contains([
      "us-central1", "us-east1", "us-west1", "europe-west1",
      "asia-southeast1", "australia-southeast1"
    ], var.region)
    error_message = "Region must be a valid GCP region."
  }
}

variable "vpc_name" {
  description = "Name of the existing VPC network"
  type        = string
  default     = "ace-learning-vpc"
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "ace-learning-cluster"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.cluster_name))
    error_message = "Cluster name must be lowercase, start with letter, contain only letters, numbers, and hyphens."
  }
}

variable "master_cidr" {
  description = "CIDR range for GKE master nodes"
  type        = string
  default     = "172.16.0.0/28"
  validation {
    condition     = can(cidrhost(var.master_cidr, 0))
    error_message = "Master CIDR must be a valid CIDR range."
  }
}

variable "authorized_networks" {
  description = "List of CIDR blocks authorized to access the master"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Allow from anywhere for learning (restrict in production)
}

# Standard Node Pool Configuration
variable "standard_node_count" {
  description = "Initial number of nodes in standard node pool"
  type        = number
  default     = 2
  validation {
    condition     = var.standard_node_count >= 1 && var.standard_node_count <= 10
    error_message = "Standard node count must be between 1 and 10."
  }
}

variable "standard_machine_type" {
  description = "Machine type for standard nodes"
  type        = string
  default     = "e2-medium"
  validation {
    condition = contains([
      "e2-micro", "e2-small", "e2-medium", "e2-standard-2",
      "n1-standard-1", "n1-standard-2", "n2-standard-2"
    ], var.standard_machine_type)
    error_message = "Machine type must be a valid GCP machine type."
  }
}

variable "standard_min_nodes" {
  description = "Minimum number of nodes in standard node pool"
  type        = number
  default     = 1
}

variable "standard_max_nodes" {
  description = "Maximum number of nodes in standard node pool"
  type        = number
  default     = 5
}

# Spot Node Pool Configuration
variable "spot_node_count" {
  description = "Initial number of nodes in spot node pool"
  type        = number
  default     = 1
  validation {
    condition     = var.spot_node_count >= 0 && var.spot_node_count <= 5
    error_message = "Spot node count must be between 0 and 5."
  }
}

variable "spot_machine_type" {
  description = "Machine type for spot nodes"
  type        = string
  default     = "e2-medium"
}

variable "spot_min_nodes" {
  description = "Minimum number of nodes in spot node pool"
  type        = number
  default     = 0
}

variable "spot_max_nodes" {
  description = "Maximum number of nodes in spot node pool"
  type        = number
  default     = 3
}

# Common Node Configuration
variable "node_disk_size" {
  description = "Disk size in GB for nodes"
  type        = number
  default     = 50
  validation {
    condition     = var.node_disk_size >= 10 && var.node_disk_size <= 100
    error_message = "Node disk size must be between 10 and 100 GB."
  }
}
