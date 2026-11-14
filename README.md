# GCP Cloud Engineering Lab

Hands-on labs for Google Cloud networking, Terraform, Compute Engine, Cloud Run, Cloud SQL, and GKE. Built as a learning portfolio for the GCP Associate Cloud Engineer certification.

## Contents

- `1-concepts/`: GCP concepts and learning notes
- `2-scripts/`: standalone gcloud examples
- `3-iac/`: VPC and GKE Terraform root modules
- `4-apps/hello-cloud-run/`: Spring Boot container for Cloud Run
- `4-apps/hello-gke/`: Spring Boot container and Kubernetes manifests
- `5-cheat-sheets/`: CLI notes and reference material
- [ROADMAP.md](ROADMAP.md): prioritized fixes and remaining verification work

## Getting started without cloud charges

Requirements: Java 17, Maven 3.9+, Docker (optional), Bash. To work with GCP, also install `gcloud`, Terraform and `kubectl`.

```bash
(cd 4-apps/hello-cloud-run && mvn clean verify)
(cd 4-apps/hello-gke && mvn clean verify)
docker build -t hello-cloud-run:local 4-apps/hello-cloud-run
docker build -t hello-gke:local 4-apps/hello-gke
```

GitHub Actions runs Java tests, container image builds, Bash syntax checks, Kubernetes YAML parsing, and Terraform formatting/validation. These static checks do **not** constitute a successful live GCP deployment.

For infrastructure setup, security requirements and destroy steps, read [3-iac/README.md](3-iac/README.md). For an end-to-end optional Cloud Run walkthrough, see [Cloud Run deployment guide](4-apps/hello-cloud-run/DEPLOYMENT.md).

## Security and costs

**Warning:** Deployment scripts can create billable GCP assets: GKE clusters, Compute Engine VMs, Cloud SQL backups, Cloud NAT, IP addresses and load balancers. Review active billing/project configuration and delete resources after experimentation. Never commit credentials, Terraform state, or service-account keys. Default Terraform access is restricted; replace placeholder operator CIDRs before deploying.

Examples are for learning, **not** evidence of live deployment or production hardening by themselves. Track outstanding verification in [ROADMAP.md](ROADMAP.md).
