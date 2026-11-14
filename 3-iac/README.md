# Terraform infrastructure labs

These are **learning examples, not production-ready infrastructure**. Applying them creates billable Google Cloud resources including GKE nodes, Cloud NAT, a global IP address, and load balancing resources.

## Layout

- `vpc-setup/`: VPC, public and private subnets, GKE secondary CIDRs, firewall rules, NAT, and a reserved global address.
- `gke-cluster/`: Private-node GKE cluster, standard and Spot node pools, workload identity and monitoring. References an existing VPC (it does not manage remote state between folders).

**Not implemented:** VPC peering, remote Terraform state backend, and state locking. Each directory uses local state unless you explicitly configure your own backend. Keep local `terraform.tfstate` files private and avoid concurrent applies.

## Prerequisites

Install Terraform, Google Cloud SDK, and authenticate using an account authorized to access the selected GCP project.

```bash
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
gcloud services enable compute.googleapis.com container.googleapis.com iam.googleapis.com
```

Edit both `terraform.tfvars` files with your actual project ID. In `gke-cluster/terraform.tfvars`, **replace `192.0.2.0/32` with your actual operator public IPv4 address as a /32**. This placeholder is a documentation-only network and deliberately does not permit access. The SSH firewall allows GCP IAP's `35.235.240.0/20` range by default; IAP IAM permissions must also be configured to connect.

## Validate first (no resources created)

```bash
terraform fmt -recursive 3-iac
for dir in 3-iac/vpc-setup 3-iac/gke-cluster; do
  (cd "$dir" && terraform init -backend=false && terraform validate)
done
```

For a live plan, GCP credentials, APIs, and correct project-specific inputs are required:

```bash
cd 3-iac/vpc-setup
terraform plan
terraform apply
cd ../gke-cluster
terraform plan
terraform apply
```

**Do not run `apply` unless you accept costs.** A plan is not proof of a successful deployment. The GKE module expects the VPC and both subnets to exist already.

## Cleanup and cost verification

Destroy the cluster *first*, then the network resources, using the same credentials and state files used for apply:

```bash
(cd 3-iac/gke-cluster && terraform destroy)
(cd 3-iac/vpc-setup && terraform destroy)
```

Confirm both Terraform states have no remaining managed resources using `terraform state list`. Also check GCP Console for leftover GKE clusters, Compute Engine VMs, reserved addresses, NAT routers, persistent disks and load balancers; inspect the Billing console to confirm no unexpected ongoing charges. Terraform state alone may not include resources created outside Terraform.

## Technical limitations

- These two directories are independent root modules, not reusable child modules.
- Project IAM, API enablement and state backends require operator setup.
- Do not use `0.0.0.0/0` for SSH or GKE control-plane access.
- GKE private nodes still require correctly configured NAT egress and IAM for image pulls.
