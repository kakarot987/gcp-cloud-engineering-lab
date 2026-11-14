# Cloud lab cost and cleanup checklist

> **Billing warning:** Some lab commands create chargeable GCP resources. Never run everything at once just to test it. Confirm the active project with `gcloud config get-value project` and review each command before running.

## Per-lab teardown examples

```bash
# GKE from 2-scripts/setup-gke.sh (adjust variables first)
gcloud container clusters delete CLUSTER_NAME --zone=ZONE --project=PROJECT_ID

# GCE from 2-scripts/deploy-gce.sh
gcloud compute instances delete INSTANCE_NAME --zone=ZONE --project=PROJECT_ID

# Cloud Run from 2-scripts/deploy-cloud-run.sh
gcloud run services delete SERVICE_NAME --region=REGION --project=PROJECT_ID

# Terraform-managed assets (run cluster destroy before VPC destroy)
(cd 3-iac/gke-cluster && terraform destroy)
(cd 3-iac/vpc-setup && terraform destroy)
```

A cluster delete does **not** necessarily remove a separately created VPC/subnet. If `setup-gke.sh` created `gke-vpc` and `gke-vpc-subnet`, inspect dependencies and then remove the subnet in the matching region and the VPC after clusters are gone.

Cloud SQL on-demand backups can incur storage charges. Identify the correct backup and assess retention policies before deleting it; never destroy your only recovery copy.

## Verify no remaining resources

```bash
gcloud container clusters list --project=PROJECT_ID
gcloud compute instances list --project=PROJECT_ID
gcloud compute addresses list --project=PROJECT_ID
gcloud compute forwarding-rules list --project=PROJECT_ID
gcloud compute routers list --project=PROJECT_ID
gcloud run services list --project=PROJECT_ID
gcloud sql instances list --project=PROJECT_ID
```

Check persistent disks, Cloud NAT settings, Artifact Registry repositories, Cloud SQL backup inventory and GCP Billing console. Confirm the resources you created no longer exist and inspect billing for delayed usage reporting.
