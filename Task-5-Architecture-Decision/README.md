# ADR: Tenant Isolation for Vendor Applications on Shared GKE / Shared VPC

## Status
Proposed

## Context
Flowvelly Healthcare is modernizing on GCP with a single org hierarchy containing `qa`, `preprod`, and `prod` folders. The platform uses a shared-host GKE cluster attached to a Shared VPC host project, with workloads relying on GKE, Cloud SQL (Postgres), and Cloud Storage. The estate is managed across Flowvelly and partner vendor teams, with inconsistent CI/CD practices and copy-pasted Terraform. The workload handles PHI-bordering data, so least privilege, change governance, and audit evidence are required.

## Decision
Adopt a tenant isolation model based on separate Kubernetes namespaces per vendor app, combined with dedicated GKE node pools, workload identity bindings, and Shared VPC firewall segmentation. This model balances vendor autonomy and shared platform efficiency while limiting blast radius for PHI-sensitive workloads.

## Options considered

### Option 1: Fully isolated projects per vendor
- Pros: strongest boundary for data, IAM, network, and audit. Easy to enforce policy separation.
- Cons: high operational cost, duplicated infrastructure, heavier onboarding, and poor fit for the existing shared-host Shared VPC model.

### Option 2: Namespace isolation on shared GKE with shared nodes
- Pros: low cost, easy to onboard vendors, aligns with current shared cluster approach.
- Cons: weak host-level separation, harder to guarantee PHI isolation, and greater risk from noisy neighbors.

### Option 3: Namespace isolation plus dedicated node pools and shared VPC segmentation (recommended)
- Pros: improved isolation without full project overhead; enables stronger runtime controls, taints/tolerations, and network policy enforcement.
- Cons: some complexity in cluster management, requires disciplined workload identity and network policy configuration.

## Rationale
Option 3 is recommended because Flowvelly Healthcare already operates in a shared-host environment and needs PHI-aware isolation without the cost of full project proliferation. Separate node pools reduce the risk of noisy neighbors and permit stricter scheduling/security policies per vendor. Namespaces preserve operational consistency and allow platform-level controls such as admission policies, policy enforcement, and service mesh traffic policies if adopted later.

Key reasons:
- PHI-bordering workloads must not share compute with untrusted vendor applications without strong runtime controls.
- Fully isolated projects would be safer, but platform and partner governance already rely on shared VPC and shared-host GKE.
- The existing shared tooling can be extended with namespace-level and node-pool isolation faster than a full project separation.
- Audit evidence is easier to collect if vendor workloads are logically grouped and platform ownership is centralized.

## Implementation approach
1. Create one namespace per vendor application in each environment (`qa`, `preprod`, `prod`).
2. Reserve dedicated node pools for each vendor namespace using taints and tolerations.
3. Use Workload Identity for all pods and bind vendor-specific Kubernetes service accounts to least-privilege GCP service accounts.
4. Apply Kubernetes NetworkPolicies plus Shared VPC firewall rules to restrict traffic between namespaces and to Cloud SQL / Cloud Storage.
5. Enforce Pod Security Standards / OPA/Gatekeeper policies for image source, container runtime, and secret access.
6. Document tenant boundaries and maintain a vendor ownership matrix: partner owns namespace workload config, platform owns Shared VPC + node pool lifecycle.

## Trade-offs
- Stronger isolation than shared-node namespaces, but weaker than full project isolation.
- Requires more platform discipline: node pool capacity planning, namespace quota management, and enforcement of network policies.
- Can still expose host-level vulnerabilities if node pools share the same underlying cluster OS and kernel; mitigate with GKE node auto-upgrades and node hardening.

## What to validate first
- That Workload Identity bindings are correctly scoped per namespace and that no vendor namespace has excessive IAM permissions.
- That dedicated node pools are actually isolated via taints/tolerations and do not host cross-tenant pods.
- That Cloud SQL and Cloud Storage access is restricted by service account and network path, not by broad project-level permissions.
- That audit logging is enabled for all namespace-level actions, network policy denies, and Cloud Audit Logs capture host-project changes.

## Rejected AI-suggested option
An AI draft suggested a simpler shared-namespace model with only RBAC isolation. I rejected it because it is too weak for PHI-bordering vendor applications in a shared GKE/Shared VPC environment. My judgment overrode the tool by prioritizing a model with concrete runtime and network segmentation rather than a generic “just use namespaces” answer.

## AI Companion Note
I used AI to draft the ADR structure and enumerate options, then critically reviewed it for healthcare-specific risk. I corrected two concrete shortfalls: the AI’s generic namespace-only isolation recommendation and its omission of Shared VPC / host-project audit governance. I added practical validation steps and a stronger rationale for dedicated node pools plus tenant namespace boundaries.
