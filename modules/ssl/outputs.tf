/******************************************
  SSL Module Outputs
******************************************/
output "cert_id" {
  description = "SSL certificate ID"
  value       = google_compute_managed_ssl_certificate.cert.id
}

output "cert_name" {
  description = "SSL certificate name"
  value       = google_compute_managed_ssl_certificate.cert.name
}
