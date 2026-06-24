# AI Companion Note

## How AI was used
- Used AI to bootstrap the GitHub Actions structure, environment gating pattern, and audit artifact concept.
- Generated pipeline jobs for build, scan, IaC validation, deploy, promotion gating, and rollback.
- Added comments and security controls that are specific to a healthcare GCP modernization estate.

## Concrete shortfalls corrected
- Added an actual image scan step using Trivy instead of skipping scanning.
- Removed any proposal to log secrets; secrets are passed through GitHub encrypted secrets and GCP Secret Manager.
- Added explicit approval gating through GitHub protected environments for `preprod` and `prod`.
- Added audit evidence artifacts recording `who/what/when/approval`.
- Documented assumptions around private/locked-down GKE networking and Workload Identity.

## What was added beyond AI output
- A QA deployment workflow that ties image builds, IaC checks, and deployment together.
- A separate promotion workflow that forces manual approval and records audit evidence.
- A rollback workflow for fast remediation using `kubectl rollout undo`.
- A concise README for operational handoff and security assumptions.
