# AI Companion Note

I used AI assistants (Claude and ChatGPT) to accelerate the initial solution design, Terraform scaffolding, documentation generation, and review of GCP resources.

AI was useful for producing a starting structure quickly, but the generated output required engineering review before it could be considered suitable for a healthcare environment.

### Shortfall 1 – Insecure Secret Handling

The initial output created Cloud SQL users using passwords directly supplied through Terraform variables. While functional, this approach exposes secrets in Terraform state files and does not align with least-privilege principles.

**Correction:** I replaced this pattern with Secret Manager integration and documented IAM-based authentication as the preferred approach.

### Shortfall 2 – Incomplete Private Cloud SQL Configuration

The generated configuration attached Cloud SQL to a private network but omitted Private Service Access requirements such as Service Networking peering.

**Correction:** I added the required networking components and verified the implementation against Google Cloud documentation.

### Shortfall 3 – Compliance Gaps

The generated output focused primarily on infrastructure provisioning and did not adequately address healthcare audit requirements.

**Correction:** I added:

* Audit logging considerations
* Public access prevention
* CMEK support
* Retention controls
* Least-privilege IAM recommendations
* Change approval and promotion guidance

### What I Added Beyond AI Output

* Shared VPC service-project architecture aligned with the assignment scenario
* Environment promotion strategy (QA → PreProd → Prod)
* Healthcare-focused security controls
* Validation of Terraform resources against provider documentation
* Explicit assumptions and operational considerations

### Remaining Limitations

This submission assumes an existing Shared VPC host project, existing KMS key management processes, and organizational policies that were not fully specified in the brief. In a production engagement, these assumptions would be validated with the customer before implementation.
