variable "project_id" {
  description = "ID of the service project to create. Must be globally unique."
  type        = string
}

variable "project_name" {
  description = "Optional display name for the service project."
  type        = string
  default     = null
}

variable "billing_account_id" {
  description = "Billing account ID used for the service project."
  type        = string
}

variable "folder_id" {
  description = "Folder ID under the organization where the service project is created."
  type        = string
  default     = null
}

variable "org_id" {
  description = "Organization ID used if the project should be created directly under the org instead of a folder."
  type        = string
  default     = null
}

variable "environment" {
  description = "Deployment environment label (qa, preprod, prod)."
  type        = string
  validation {
    condition     = length(regexall("^[a-z0-9-]+$", var.environment)) > 0
    error_message = "environment must be lowercase letters, digits, or hyphen."
  }
}

variable "host_project_id" {
  description = "Host Shared VPC project ID that owns the shared network."
  type        = string
}

variable "shared_vpc_network_name" {
  description = "Name of the Shared VPC network in the host project."
  type        = string
}

variable "location" {
  description = "Primary location for project-scoped resources."
  type        = string
  default     = "us-central1"
}

variable "bucket_location" {
  description = "Location for the storage bucket."
  type        = string
  default     = "US"
}

variable "bucket_cmek_key_name" {
  description = "Optional CMEK resource name used for bucket encryption."
  type        = string
  default     = null
}

variable "db_version" {
  description = "Cloud SQL Postgres database version."
  type        = string
  default     = "POSTGRES_15"
}

variable "db_tier" {
  description = "Cloud SQL machine type."
  type        = string
  default     = "db-custom-2-7680"
}

variable "db_region" {
  description = "Cloud SQL regional location."
  type        = string
  default     = "us-central1"
}

variable "db_user" {
  description = "Database user for the Cloud SQL instance."
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Password for the Cloud SQL user. Must be provided outside checked-in files."
  type        = string
  sensitive   = true
}

variable "service_account_id" {
  description = "Service account ID for workload-identity usage."
  type        = string
  default     = "gke-workload-identity"
}

variable "k8s_namespace" {
  description = "Kubernetes namespace for the workload identity binding."
  type        = string
  default     = null
}

variable "k8s_service_account_name" {
  description = "Kubernetes service account name for workload identity binding."
  type        = string
  default     = null
}

variable "gke_project_id" {
  description = "GKE cluster project ID used for workload identity principals."
  type        = string
  default     = null
}

variable "labels" {
  description = "Additional labels applied to created resources."
  type        = map(string)
  default     = {}
}

variable "required_apis" {
  description = "APIs automatically enabled in the service project."
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "iamcredentials.googleapis.com"
    "servicenetworking.googleapis.com"
    "secretmanager.googleapis.com"
    "cloudkms.googleapis.com"
  ]
}

variable "audit_bucket_suffix" {
  description = "Suffix for the audit-log bucket to keep logging targets separate."
  type        = string
  default     = "audit-logs"
}

variable "service_bucket_suffix" {
  description = "Suffix for the main data bucket."
  type        = string
  default     = "service-bucket"
}

variable "project_parent_type" {
  description = "Parent type for project creation. Must be either folder or organization."
  type        = string
  default     = "folder"
  validation {
    condition     = contains(["folder", "organization"], var.project_parent_type)
    error_message = "project_parent_type must be either 'folder' or 'organization'."
  }
}
