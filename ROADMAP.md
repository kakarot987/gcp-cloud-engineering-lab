# GCP Cloud Engineering Lab — Roadmap

**Progress: 0/12 completed**

This tracker prioritizes fixes needed to make the lab reliable, secure by default, reproducible, and suitable as evidence of hands-on cloud deployment experience.

## Critical findings

### Cloud Run Docker build

The Dockerfile runs:

```dockerfile
RUN ./mvnw clean package -DskipTests
```

The application does not include a Maven wrapper available to that build, and the Dockerfile neither installs Maven nor copies the wrapper. Use a Maven build stage or add/copy the wrapper and verify a clean Docker image build.

### Overlapping GKE address ranges

`setup-gke.sh` defines a primary subnet CIDR of `10.0.0.0/16` and a Services secondary CIDR of `10.0.16.0/20`. The latter falls within the former; GCP requires distinct, non-overlapping primary and secondary address ranges. Allocate unique CIDRs before provisioning.

### Overly permissive access defaults

Terraform currently defaults SSH ingress and GKE control-plane authorized networks to `0.0.0.0/0`. Even in an educational repository, prefer narrow, secure defaults and clearly documented opt-in changes for experiments.

## Additional code and configuration findings

| Priority | File / area | Issue and proposed fix |
| --- | --- | --- |
| P0 | `3-iac/gke-cluster/main.tf` | Spot node pool uses `taints = [...]`; replace with provider-supported `taint { ... }` blocks inside `node_config`, then validate. |
| P0 | `2-scripts/backup-sql.sh` | `gcloud sql backups create` does not accept the script's positional backup ID. Correct invocation, retrieve the actual backup identifier, and poll using that ID. |
| P0 | `4-apps/hello-gke/k8s/service.yaml` | LoadBalancer annotation is under `spec` rather than `metadata.annotations`. Move and validate. |
| P1 | `hello-gke/pom.xml` | Prometheus actuator endpoint is documented, but `micrometer-registry-prometheus` is absent. Add the dependency or correct the documentation. |
| P1 | `3-iac/README.md` | VPC peering and remote Terraform state with locking are claimed but not evidently implemented. Implement them or remove the claims. |
| P1 | `hello-gke/HelloController.java` | `/health` simulates database status `UP`; `/ready` always reports ready. Label as simulated or use real Spring Boot health/readiness indicators. |
| P1 | `2-scripts/deploy-gce.sh` | Generated HTML attempts to fetch GCE instance metadata from a visitor's browser. Fetch on the server and expose only explicitly selected safe values. |
| P2 | Repository-wide | Add CI and tests; remove tracked `.idea` files; review older Spring Boot and Terraform provider versions; improve top-level setup documentation. |

## Improvement tracker

### P0 — Deployment blockers

- [ ] Fix the Cloud Run Dockerfile and verify a clean image build
- [ ] Correct overlapping GKE IP ranges in `setup-gke.sh`
- [ ] Correct the Terraform Spot node pool taint configuration
- [ ] Fix the Cloud SQL backup command and polling logic
- [ ] Move the Kubernetes Service annotation to `metadata`

### P1 — Validation, security, and demonstration

- [ ] Run `terraform fmt`, `terraform validate`, and `terraform plan` in both infrastructure directories
- [ ] Add tests and CI for both Spring Boot applications
- [ ] Harden SSH and GKE control-plane access defaults
- [ ] Add Prometheus registry support or correct metrics documentation
- [ ] Demonstrate one end-to-end Cloud Run deployment

### P2 — Documentation and portfolio polish

- [ ] Update README claims, remove tracked IDE files, and document costs
- [ ] Consider shared deployment examples with `K8s-App-Shipping`

## Cost warnings and cleanup requirements

> **Cost warning:** These scripts can provision billable Google Cloud resources—including GKE clusters, virtual machines, Cloud NAT, external IP addresses, and load balancers. Some resources may continue accruing charges while idle.

Before encouraging others to run the labs:

1. Add explicit cost and billing-project warnings to each provisioning walkthrough.
2. Document cleanup/teardown commands per lab, including `terraform destroy` where appropriate.
3. Verify that clusters, node pools, VMs, load balancers, NAT gateways, forwarding rules, reserved addresses, disks, and other billable dependencies are removed.
4. Instruct users to check the active GCP project and Billing console for remaining charges/resources.

**Definition of done:** P0 issues are fixed and validated, infrastructure and applications are tested, an end-to-end Cloud Run deployment is documented, and the examples clearly explain costs and cleanup.
