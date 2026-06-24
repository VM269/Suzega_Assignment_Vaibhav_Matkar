provider "google" {
  project = var.host_project_id
  region  = var.location
}

module "service_project" {
  source = "../../modules/gcp_service_project"

  project_id              = var.project_id
  billing_account_id      = var.billing_account_id
  folder_id               = var.folder_id
  environment             = var.environment
  host_project_id         = var.host_project_id
  shared_vpc_network_name = var.shared_vpc_network_name
  location                = var.location
  bucket_location         = var.bucket_location
  db_password             = var.db_password
  db_user                 = var.db_user

  gke_project_id           = var.gke_project_id
  k8s_namespace            = var.k8s_namespace
  k8s_service_account_name = var.k8s_service_account_name
}
