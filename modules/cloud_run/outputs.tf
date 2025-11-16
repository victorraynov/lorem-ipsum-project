/******************************************
  Cloud Run Module Outputs
******************************************/
output "service_url" {
  description = "Service URL"
  value       = google_cloud_run_v2_service.service.uri
}

output "service_account" {
  description = "Service account email"
  value       = google_service_account.cloud_run_sa.email
}
