# Flowvelly Healthcare GKE CI/CD & Safe Promotion

## Why GitHub Actions
- GitHub Actions is chosen because it provides repository-native secrets, protected environments, approval gating, and built-in audit evidence for workflow promotions.
- It aligns with a shared-ownership healthcare environment where audit trails and environment review are mandatory.

## Pipeline overview
- `build-and-qa.yml`
  - builds container image for the inference service
  - scans the image with Trivy
  - validates Terraform IaC in `infra/`
  - deploys to `qa` on branch `qa`
- `promotion.yml`
  - provides gated promotions to `preprod` and `prod`
  - uses GitHub environment protection to capture reviewer approval and audit logs
- `rollback.yml`
  - supports fast rollback via `kubectl rollout undo`
  - stores rollback evidence as a pipeline artifact

## Security assumptions
- `GCP_SA_KEY` is a GitHub secret containing a service account key JSON with least privileges:
  - Artifact Registry push
  - GKE get-credentials / workload deployment
  - Secret Manager access (read) for workload secrets
  - Cloud SQL IAM roles only if required by the inference service
- `QA_CLUSTER_NAME`, `QA_CLUSTER_LOCATION`, `PREPROD_CLUSTER_NAME`, `PREPROD_CLUSTER_LOCATION`, `PROD_CLUSTER_NAME`, and `PROD_CLUSTER_LOCATION` are stored as GitHub secrets.
- The GKE clusters are assumed to be private or in a locked-down Shared VPC.
- The inference workload uses Workload Identity so application secrets are read from Secret Manager, not committed to Git.

## Audit evidence and gating
- `promotion.yml` requires GitHub environment approval for `preprod` and `prod`.
- `promotion.yml` and `rollback.yml` each generate `promotion-audit` / `rollback-audit` artifacts with:
  - who: actor identity
  - what: promotion or rollback action
  - when: UTC timestamp
  - image/deployment details
  - approval source: GitHub environment protection
- `build-and-qa.yml` creates a `qa-deploy-audit` artifact for traceability even when QA is automated.

## Secrets handling
- No secret values are stored in repo YAML.
- `GCP_SA_KEY` is only referenced in the actions runtime and never printed.
- `kubectl` deploys use `envsubst` to substitute private image tags from environment variables.
- Production workloads are assumed to use Secret Manager + Workload Identity instead of hard-coded Kubernetes secrets.

## Fast rollback
- Use `rollback.yml` with `workflow_dispatch`.
- It performs a `kubectl rollout undo` and waits for rollout success in the target environment.

## Notes for Flowvelly Healthcare
- This pattern fixes generic AI output gaps by explicitly adding image scanning, environment gate metadata, and runtime secret management.
- It also assumes and documents the need for a locked-down VPC/Private GKE cluster, an audit-enabled GitHub repository, and reviewer approval flows for preprod/prod.
