# AI Judgment

The generated GitHub Actions CI/CD pipeline needed targeted corrections for a healthcare GCP estate.

### Issues identified
- The initial AI output did not explicitly provide approval gating or audit evidence for promotions to sensitive environments.
- It also risked secrets exposure if secret handling was not clearly separated from repo content and logs.
- The initial workflow had a missing connection between build output and QA deployment, which would break the pipeline.

### Fixes applied
- Added GitHub protected environment approval gating for `preprod` and `prod`.
- Added audit artifact generation for QA deploy, promotion, and rollback with `who/what/when/approval` details.
- Enforced image scanning with Trivy and uploaded a JSON report.
- Documented assumptions about least-privilege service accounts, private/Shared VPC GKE, and Workload Identity for runtime secret access.
- Fixed the QA deployment job to consume the built image tag output from the build job.

### Why this matters for Flowvelly Healthcare
For a PHI-bordering shared ownership workload, the pipeline must be auditable and gated, secrets must never appear in plaintext, and deployment logic must be correct. These changes make the CI/CD flow appropriate for a healthcare modernization program rather than a generic example.
