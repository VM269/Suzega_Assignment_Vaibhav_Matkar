# Flowvelly Healthcare GCP Shared-VPC Service Project Module

This workspace contains a reusable Terraform module for provisioning a compliant GCP Shared-VPC service project for Flowvelly Healthcare.

## What is included

- Service project creation under a folder or org
- Required APIs enabled in the new service project
- Least-privilege GKE workload identity service account
- Workload identity binding to a named GKE service account
- Private-IP Cloud SQL Postgres instance attached to Shared VPC
- Encrypted, logged, private Cloud Storage bucket
- Environment promotion examples for qa, preprod, and prod
- Safe secret/state guidance for healthcare-sensitive data

## Promotion workflow

1. Keep the reusable module under `modules/gcp_service_project`
2. Create one environment root per lifecycle stage: `environments/qa`, `environments/preprod`, `environments/prod`
3. Keep backend config separate and use remote state in GCS
4. Supply sensitive values via `TF_VAR_db_password` or secret manager, not checked-in `.tfvars`
5. Promote by applying the same module source path in the next environment with a new `project_id`, state prefix, and approvals

## Validation

This module was authored for Terraform `>= 1.4` and Google provider `~> 5.0`.
Run:

```bash
cd environments/qa
terraform init
terraform plan -var-file=terraform.tfvars
```

## Notes

- The module avoids `owner` and `editor` roles.
- The module is private-by-default and enforces `public_access_prevention`.
- Use the module output values to wire higher-level CI/CD or policy automation.
