/******************************************
  Service Account Module Outputs
******************************************/
output "email" {
  description = "Service account email"
  value       = google_service_account.sa.email
}

output "name" {
  description = "Service account name"
  value       = google_service_account.sa.name
}
