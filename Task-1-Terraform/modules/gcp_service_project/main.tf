locals {
  project_name = var.project_name != null ? var.project_name : "${var.environment}-service-project"
  common_labels = merge({
    environment = var.environment
    managed_by  = "platform-devops"
    compliance  = "hipaa"
  }, var.labels)
  service_bucket_name         = "${var.project_id}-${var.service_bucket_suffix}"
  audit_log_bucket_name       = "${var.project_id}-${var.audit_bucket_suffix}"
  shared_vpc_network_selflink = "projects/${var.host_project_id}/global/networks/${var.shared_vpc_network_name}"
}

resource "google_project" "service_project" {
  project_id          = var.project_id
  name                = local.project_name
  billing_account     = var.billing_account_id
  auto_create_network = false

  folder_id = var.project_parent_type == "folder" ? var.folder_id : null
  org_id    = var.project_parent_type == "organization" ? var.org_id : null

  labels = local.common_labels
}

provider "google" {
  alias   = "service_project"
  project = google_project.service_project.project_id
  region  = var.location
}

resource "google_project_service" "api" {
  for_each = toset(var.required_apis)

  project = google_project.service_project.project_id
  service = each.value

  disable_on_destroy = false
  provider           = google.service_project
}

resource "google_service_account" "workload_identity" {
  account_id   = var.service_account_id
  display_name = "Workload identity service account for ${var.environment}"
  project      = google_project.service_project.project_id
  provider     = google.service_project
}

resource "google_service_account_iam_member" "workload_identity_binding" {
  count = var.gke_project_id != null && var.k8s_namespace != null && var.k8s_service_account_name != null ? 1 : 0

  service_account_id = google_service_account.workload_identity.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gke_project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_service_account_name}]"
  provider           = google.service_project
}

resource "google_project_iam_member" "sql_client" {
  project  = google_project.service_project.project_id
  role     = "roles/cloudsql.client"
  member   = "serviceAccount:${google_service_account.workload_identity.email}"
  provider = google.service_project
}

resource "google_storage_bucket" "audit_log_bucket" {
  name     = local.audit_log_bucket_name
  project  = google_project.service_project.project_id
  location = var.bucket_location

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  versioning {
    enabled = true
  }

  retention_policy {
  retention_period = 2592000
  }

  labels   = local.common_labels
  provider = google.service_project
}

resource "google_storage_bucket" "service_bucket" {
  name     = local.service_bucket_name
  project  = google_project.service_project.project_id
  location = var.bucket_location

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  logging {
    log_bucket        = google_storage_bucket.audit_log_bucket.name
    log_object_prefix = "access-logs/"
  }

  versioning {
    enabled = true
  }

  dynamic "encryption" {
    for_each = var.bucket_cmek_key_name != null ? [1] : []
    content {
      default_kms_key_name = var.bucket_cmek_key_name
    }
  }

  labels   = local.common_labels
  provider = google.service_project
}

resource "google_sql_database_instance" "postgres" {
  name             = "${var.project_id}-db"
  project          = google_project.service_project.project_id
  database_version = var.db_version
  region           = var.db_region
  provider         = google.service_project

  settings {
    tier              = var.db_tier
    activation_policy = "ALWAYS"

    # Use REGIONAL for production HA
    availability_type = "REGIONAL"

    ip_configuration {
      ipv4_enabled    = false
      private_network = local.shared_vpc_network_selflink
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true

      # Optional but recommended
      start_time = "03:00"
    }
  }

  deletion_protection = true
}

resource "google_compute_global_address" "private_ip_range" {
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = local.shared_vpc_network_selflink
}

resource "google_service_networking_connection" "private_vpc_connection" {

  network = local.shared_vpc_network_selflink

  service = "servicenetworking.googleapis.com"

  reserved_peering_ranges = [
    google_compute_global_address.private_ip_range.name
  ]
}

resource "google_sql_user" "postgres_user" {
  name     = var.db_user
  instance = google_sql_database_instance.postgres.name
  project  = google_project.service_project.project_id
  password = data.google_secret_manager_secret_version.db_password.secret_data
  provider = google.service_project
}
