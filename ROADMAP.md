# GCP Cloud Engineering Lab — Roadmap

## Status (code changes vs real-world validation)

P0 remediation has been **implemented in the fix branch**, but actual Docker builds, Terraform provider validation/plans and a Cloud Run deployment must still be confirmed in CI or in an authenticated GCP environment. Do not claim a verified deployment until evidence (logs, plan, service URL) is recorded.

## Priority checklist

### P0

- [ ] Verify clean Cloud Run Docker build (Maven builder configured; awaiting CI)
- [x] Correct overlapping GKE IP ranges in `setup-gke.sh`
- [x] Correct Terraform Spot node pool taint configuration
- [ ] Verify Cloud SQL backup command and polling against a real SQL instance (correct invocation and identifier lookup implemented)
- [x] Move Kubernetes Service annotation to `metadata`

### P1

- [ ] Run `terraform fmt`, `terraform validate` and authenticated `terraform plan` in both infrastructure directories (CI checks configured; plan requires GCP)
- [x] Add basic tests and CI for both Spring Boot applications (CI execution to be confirmed)
- [x] Harden SSH and GKE control-plane access defaults
- [x] Add Prometheus Micrometer registry dependency
- [ ] Demonstrate one end-to-end Cloud Run deployment (guide added; live deployment outstanding)

### P2

- [x] Update README claims, stop tracking IDE files and document costs/cleanup
- [ ] Consider shared deployment examples with `K8s-App-Shipping`

## Further technical improvements

- Replace the prior simulated `hello-gke` database health with actual Actuator health; readiness uses Spring Boot availability. Kubernetes probes now target Actuator liveness/readiness.
- Fix GCE visitor-side metadata fetching by rendering a static page with selected, escaped instance metadata on the VM.
- Confirm CI and provider compatibility before upgrading older Spring Boot / Google Terraform provider versions. Keep security updates and breaking-version upgrades as separately tested changes.
- Consider adding Terraform state backend configuration and state locking as an explicit optional exercise.
- Add stronger integration tests and test a real deployment in a sandbox GCP project.

## Safety

See [CLEANUP.md](CLEANUP.md) before provisioning resources. GKE clusters, NAT, VMs, Cloud SQL backups and load balancers can create ongoing charges. No resources were provisioned as part of these repository edits.
