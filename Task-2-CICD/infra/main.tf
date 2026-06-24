terraform {
  required_version = ">= 1.7.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_secret_manager_secret" "inference_service_config" {
  secret_id = "inference-service-config"
  replication {
    automatic = true
  }
}

output "secret_name" {
  value = google_secret_manager_secret.inference_service_config.id
}
