# GKE Cluster Module - outputs.tf
# Output values for cluster access and configuration

output "cluster_id" {
  description = "ID of the GKE cluster"
  value       = google_container_cluster.gke_cluster.id
}

output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.gke_cluster.name
}

output "cluster_endpoint" {
  description = "Endpoint for the GKE cluster"
  value       = google_container_cluster.gke_cluster.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate for the cluster"
  value       = google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "Location of the GKE cluster"
  value       = google_container_cluster.gke_cluster.location
}

output "cluster_master_version" {
  description = "Kubernetes master version"
  value       = google_container_cluster.gke_cluster.master_version
}

output "cluster_network" {
  description = "VPC network name"
  value       = google_container_cluster.gke_cluster.network
}

output "cluster_subnetwork" {
  description = "Subnetwork name"
  value       = google_container_cluster.gke_cluster.subnetwork
}

output "standard_node_pool_name" {
  description = "Name of the standard node pool"
  value       = google_container_node_pool.standard_nodes.name
}

output "standard_node_pool_id" {
  description = "ID of the standard node pool"
  value       = google_container_node_pool.standard_nodes.id
}

output "spot_node_pool_name" {
  description = "Name of the spot node pool"
  value       = google_container_node_pool.spot_nodes.name
}

output "spot_node_pool_id" {
  description = "ID of the spot node pool"
  value       = google_container_node_pool.spot_nodes.id
}

output "service_account_email" {
  description = "Email of the GKE service account"
  value       = google_service_account.gke_sa.email
}

output "workload_identity_pool" {
  description = "Workload identity pool for the cluster"
  value       = google_container_cluster.gke_cluster.workload_identity_config[0].workload_pool
}

# kubectl configuration command
output "kubectl_config_command" {
  description = "Command to configure kubectl for this cluster"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.gke_cluster.name} --region ${google_container_cluster.gke_cluster.location} --project ${var.project_id}"
}

# Useful cluster information
output "cluster_info" {
  description = "Summary of cluster configuration"
  value = {
    name              = google_container_cluster.gke_cluster.name
    location          = google_container_cluster.gke_cluster.location
    version           = google_container_cluster.gke_cluster.master_version
    endpoint          = google_container_cluster.gke_cluster.endpoint
    node_pools        = [google_container_node_pool.standard_nodes.name, google_container_node_pool.spot_nodes.name]
    network_policy    = google_container_cluster.gke_cluster.network_policy[0].enabled
    private_cluster   = google_container_cluster.gke_cluster.private_cluster_config[0].enable_private_nodes
    workload_identity = google_container_cluster.gke_cluster.workload_identity_config[0].workload_pool
  }
}
