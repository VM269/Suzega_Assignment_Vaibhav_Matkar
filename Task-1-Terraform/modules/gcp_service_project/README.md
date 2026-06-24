# GCP Shared VPC Service Project Module

This Terraform module creates a reusable Google Cloud service project for Flowvelly Healthcare workloads with:

- Shared VPC service project creation under a folder or organization
- Required APIs enabled in the new project
- Least-privilege workload identity service account
- Workload Identity binding to a specified GKE service account
- Private-IP Cloud SQL Postgres instance on the host Shared VPC
- Private, encrypted, logged Storage bucket with uniform access and public access prevention
- Metadata labels for environment and compliance

## Key design decisions

- No owner/editor roles are created
- Project is private-by-default with `auto_create_network = false`
- GKE workload identity binding is optional and requires explicit Kubernetes service account details
- Cloud SQL uses private IP only and disables public IPv4
- Storage bucket access logging is enabled via a separate audit log bucket
- Secret values such as `db_password` must be supplied outside version control

## Usage

```hcl
module "service_project" {
  source = "../../modules/gcp_service_project"

  project_id              = "flowvelly-qa-service"
  billing_account_id      = var.billing_account_id
  folder_id               = var.folder_id
  environment             = "qa"
  host_project_id         = var.host_project_id
  shared_vpc_network_name = var.shared_vpc_network_name
  db_password             = var.db_password
  gke_project_id          = var.gke_project_id
  k8s_namespace           = var.k8s_namespace
  k8s_service_account_name = var.k8s_service_account_name
}
```

## Promotion pattern

Use separate environment roots for `qa`, `preprod`, and `prod` with distinct remote state backends and parameterized IDs. Keep secrets out of source control and promote using the same module source version.

- `environments/qa/`
- `environments/preprod/`
- `environments/prod/`

This supports safe environment promotion without copying Terraform resource definitions.

## Safe secret handling

- Store sensitive values like `db_password` in secure secret storage or pass them using `TF_VAR_db_password`
- Do not commit `terraform.tfstate` or `*.tfvars` containing secrets
- Use a remote backend such as GCS and grant state bucket access with least privilege
