variable "project_id" {
  description = "Service project ID for QA."
  type        = string
  default     = "flowvelly-qa-service"
}

variable "billing_account_id" {
  description = "Billing account ID for the service project."
  type        = string
}

variable "folder_id" {
  description = "Folder ID that owns the service project."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "qa"
}

variable "host_project_id" {
  description = "Host Shared VPC project ID."
  type        = string
}

variable "shared_vpc_network_name" {
  description = "Shared VPC network name."
  type        = string
}

variable "db_password" {
  description = "Cloud SQL password. Do not store in checked-in files."
  type        = string
  sensitive   = true
}

variable "db_user" {
  description = "Cloud SQL user."
  type        = string
  default     = "postgres"
}

variable "location" {
  description = "Primary region for provider operations."
  type        = string
  default     = "us-central1"
}

variable "bucket_location" {
  description = "Cloud Storage bucket location."
  type        = string
  default     = "US"
}

variable "gke_project_id" {
  description = "Project containing the GKE cluster if using workload identity."
  type        = string
  default     = null
}

variable "k8s_namespace" {
  description = "Kubernetes namespace for workload identity binding."
  type        = string
  default     = null
}

variable "k8s_service_account_name" {
  description = "Kubernetes service account name for workload identity binding."
  type        = string
  default     = null
}
