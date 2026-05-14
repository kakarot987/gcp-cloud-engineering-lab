# VPC Setup Module - outputs.tf
# Output values for use by other modules or reference

output "vpc_id" {
  description = "ID of the created VPC network"
  value       = google_compute_network.vpc_network.id
}

output "vpc_name" {
  description = "Name of the created VPC network"
  value       = google_compute_network.vpc_network.name
}

output "vpc_self_link" {
  description = "Self-link of the created VPC network"
  value       = google_compute_network.vpc_network.self_link
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = google_compute_subnetwork.public_subnet.id
}

output "public_subnet_name" {
  description = "Name of the public subnet"
  value       = google_compute_subnetwork.public_subnet.name
}

output "public_subnet_cidr" {
  description = "CIDR range of the public subnet"
  value       = google_compute_subnetwork.public_subnet.ip_cidr_range
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = google_compute_subnetwork.private_subnet.id
}

output "private_subnet_name" {
  description = "Name of the private subnet"
  value       = google_compute_subnetwork.private_subnet.name
}

output "private_subnet_cidr" {
  description = "CIDR range of the private subnet"
  value       = google_compute_subnetwork.private_subnet.ip_cidr_range
}

output "nat_router_name" {
  description = "Name of the Cloud NAT router"
  value       = google_compute_router.nat_router.name
}

output "nat_gateway_name" {
  description = "Name of the Cloud NAT gateway"
  value       = google_compute_router_nat.nat_gateway.name
}

output "load_balancer_ip" {
  description = "Static IP address for load balancer"
  value       = google_compute_global_address.lb_ip.address
}

output "network_firewall_rules" {
  description = "List of created firewall rule names"
  value = [
    google_compute_firewall.allow_ssh.name,
    google_compute_firewall.allow_web.name,
    google_compute_firewall.allow_internal.name,
    google_compute_firewall.allow_gke.name
  ]
}

# Output for GKE secondary ranges
output "public_subnet_secondary_ranges" {
  description = "Secondary IP ranges for public subnet (GKE)"
  value = {
    pods     = var.pods_secondary_cidr
    services = var.services_secondary_cidr
  }
}

output "private_subnet_secondary_ranges" {
  description = "Secondary IP ranges for private subnet (GKE)"
  value = {
    pods     = var.pods_private_secondary_cidr
    services = var.services_private_secondary_cidr
  }
}
