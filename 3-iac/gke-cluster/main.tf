# GKE Cluster Module - main.tf
# Demonstrates Kubernetes cluster provisioning with Terraform

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

# Data source to reference existing VPC (created by vpc-setup module)
data "google_compute_network" "vpc" {
  name = var.vpc_name
}

data "google_compute_subnetwork" "public_subnet" {
  name   = "${var.vpc_name}-public"
  region = var.region
}

data "google_compute_subnetwork" "private_subnet" {
  name   = "${var.vpc_name}-private"
  region = var.region
}

# GKE Cluster
resource "google_container_cluster" "gke_cluster" {
  name     = var.cluster_name
  location = var.region

  # Networking
  network    = data.google_compute_network.vpc.self_link
  subnetwork = data.google_compute_subnetwork.private_subnet.self_link

  # Enable private cluster
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_cidr
  }

  # IP allocation policy for pods and services
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods-private"
    services_secondary_range_name = "services-private"
  }

  # Enable workload identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Remove default node pool (we'll create custom ones)
  remove_default_node_pool = true
  initial_node_count       = 1

  # Enable network policy
  network_policy {
    provider = "CALICO"
    enabled  = true
  }

  # Enable GKE add-ons
  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    gcp_filestore_csi_driver_config {
      enabled = true
    }
  }

  # Master authorized networks (restrict access)
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.authorized_networks[0]
      display_name = "Public subnet"
    }
  }

  # Enable logging and monitoring
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  # Maintenance window
  maintenance_policy {
    recurring_window {
      start_time = "2024-01-01T02:00:00Z"
      end_time   = "2024-01-01T06:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
    }
  }
}

# Standard Node Pool
resource "google_container_node_pool" "standard_nodes" {
  name       = "standard-node-pool"
  location   = var.region
  cluster    = google_container_cluster.gke_cluster.name
  node_count = var.standard_node_count

  node_config {
    machine_type = var.standard_machine_type
    disk_size_gb = var.node_disk_size
    disk_type    = "pd-standard"

    # Service account for nodes
    service_account = google_service_account.gke_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Enable workload identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Node labels and taints
    labels = {
      environment = "learning"
      node-type   = "standard"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    # Shielded nodes for security
    shielded_instance_config {
      enable_secure_boot          = true
      enable_vtpm                 = true
      enable_integrity_monitoring = true
    }
  }

  # Auto-scaling
  autoscaling {
    min_node_count = var.standard_min_nodes
    max_node_count = var.standard_max_nodes
  }

  # Auto-repair and auto-upgrade
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # Upgrade settings
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
}

# Spot Instance Node Pool (cost-effective)
resource "google_container_node_pool" "spot_nodes" {
  name       = "spot-node-pool"
  location   = var.region
  cluster    = google_container_cluster.gke_cluster.name
  node_count = var.spot_node_count

  node_config {
    machine_type = var.spot_machine_type
    disk_size_gb = var.node_disk_size
    disk_type    = "pd-standard"

    # Use spot instances for cost savings
    spot = true

    service_account = google_service_account.gke_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = {
      environment = "learning"
      node-type   = "spot"
    }

    taints = [
      {
        key    = "cloud.google.com/gke-spot"
        value  = "true"
        effect = "NO_SCHEDULE"
      }
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  # Auto-scaling for spot nodes
  autoscaling {
    min_node_count = var.spot_min_nodes
    max_node_count = var.spot_max_nodes
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# Service Account for GKE nodes
resource "google_service_account" "gke_sa" {
  account_id   = "gke-nodes-sa"
  display_name = "GKE Nodes Service Account"
  description  = "Service account for GKE cluster nodes"
}

# IAM binding for GKE service account
resource "google_project_iam_member" "gke_sa_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_project_iam_member" "gke_sa_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_project_iam_member" "gke_sa_storage" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}
