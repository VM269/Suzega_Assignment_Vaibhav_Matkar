output "project_id" {
  description = "The created service project ID."
  value       = google_project.service_project.project_id
}

output "project_number" {
  description = "The created service project numeric project number."
  value       = google_project.service_project.number
}

output "workload_identity_service_account_email" {
  description = "Service account email for workload identity."
  value       = google_service_account.workload_identity.email
}

output "service_bucket_name" {
  description = "The private, logged storage bucket created in the service project."
  value       = google_storage_bucket.service_bucket.name
}

output "audit_bucket_name" {
  description = "The storage bucket that receives access logs."
  value       = google_storage_bucket.audit_log_bucket.name
}

output "sql_instance_connection_name" {
  description = "Cloud SQL instance connection name."
  value       = google_sql_database_instance.postgres.connection_name
}

output "sql_user" {
  description = "Database user created in the Cloud SQL instance."
  value       = google_sql_user.postgres_user.name
}

output "workload_identity_binding_member" {
  description = "IAM member created for workload identity binding, if configured."
  value       = google_service_account_iam_member.workload_identity_binding.*.member
}
