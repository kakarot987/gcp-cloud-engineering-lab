# VPC Setup Module - main.tf
# Demonstrates GCP networking fundamentals with Terraform

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Custom VPC Network
resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  description             = "Custom VPC for GCP ACE learning project"
}

# Public Subnet
resource "google_compute_subnetwork" "public_subnet" {
  name          = "${var.vpc_name}-public"
  ip_cidr_range = var.public_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.id

  # Enable private Google access for Cloud SQL, etc.
  private_ip_google_access = true

  # Secondary ranges for GKE pods and services
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_secondary_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_secondary_cidr
  }
}

# Private Subnet
resource "google_compute_subnetwork" "private_subnet" {
  name          = "${var.vpc_name}-private"
  ip_cidr_range = var.private_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.id

  private_ip_google_access = true

  # Secondary ranges for GKE
  secondary_ip_range {
    range_name    = "pods-private"
    ip_cidr_range = var.pods_private_secondary_cidr
  }

  secondary_ip_range {
    range_name    = "services-private"
    ip_cidr_range = var.services_private_secondary_cidr
  }
}

# Cloud Router for NAT
resource "google_compute_router" "nat_router" {
  name    = "${var.vpc_name}-nat-router"
  region  = google_compute_subnetwork.private_subnet.region
  network = google_compute_network.vpc_network.id
}

# Cloud NAT for private subnet outbound access
resource "google_compute_router_nat" "nat_gateway" {
  name                               = "${var.vpc_name}-nat"
  router                             = google_compute_router.nat_router.name
  region                             = google_compute_router.nat_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall Rules

# Allow SSH from anywhere (for learning - restrict in production)
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.vpc_name}-allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

# Allow HTTP/HTTPS from anywhere
resource "google_compute_firewall" "allow_web" {
  name    = "${var.vpc_name}-allow-web"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

# Allow internal traffic between subnets
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.vpc_name}-allow-internal"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    var.public_subnet_cidr,
    var.private_subnet_cidr
  ]
}

# Allow GKE control plane communication
resource "google_compute_firewall" "allow_gke" {
  name    = "${var.vpc_name}-allow-gke"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["10250", "443"]
  }

  source_ranges = ["172.16.0.0/28"] # GKE control plane CIDR
  target_tags   = ["gke-node"]
}

# Static IP for load balancer (optional)
resource "google_compute_global_address" "lb_ip" {
  name = "${var.vpc_name}-lb-ip"
  description = "Static IP for load balancer"
}
