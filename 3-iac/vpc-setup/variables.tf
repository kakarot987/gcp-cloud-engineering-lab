# VPC Setup Module - variables.tf
# Input variables for customizable VPC configuration

variable "project_id" {
  description = "GCP Project ID where resources will be created"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.project_id))
    error_message = "Project ID must be lowercase, start with letter, contain only letters, numbers, and hyphens."
  }
}

variable "region" {
  description = "GCP region for resources"
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
  description = "Name of the VPC network"
  type        = string
  default     = "ace-learning-vpc"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.vpc_name))
    error_message = "VPC name must be lowercase, start with letter, contain only letters, numbers, and hyphens."
  }
}

variable "public_subnet_cidr" {
  description = "CIDR range for public subnet"
  type        = string
  default     = "10.0.1.0/24"
  validation {
    condition     = can(cidrhost(var.public_subnet_cidr, 0))
    error_message = "Public subnet CIDR must be a valid CIDR range."
  }
}

variable "private_subnet_cidr" {
  description = "CIDR range for private subnet"
  type        = string
  default     = "10.0.2.0/24"
  validation {
    condition     = can(cidrhost(var.private_subnet_cidr, 0))
    error_message = "Private subnet CIDR must be a valid CIDR range."
  }
}

variable "pods_secondary_cidr" {
  description = "Secondary CIDR range for GKE pods in public subnet"
  type        = string
  default     = "10.1.0.0/16"
}

variable "services_secondary_cidr" {
  description = "Secondary CIDR range for GKE services in public subnet"
  type        = string
  default     = "10.2.0.0/20"
}

variable "pods_private_secondary_cidr" {
  description = "Secondary CIDR range for GKE pods in private subnet"
  type        = string
  default     = "10.3.0.0/16"
}

variable "services_private_secondary_cidr" {
  description = "Secondary CIDR range for GKE services in private subnet"
  type        = string
  default     = "10.4.0.0/20"
}
