/******************************************
  Load Balancer Module Outputs
******************************************/
output "lb_ip" {
  description = "Load balancer IP address"
  value       = google_compute_global_forwarding_rule.http.ip_address
}

output "backend_service_id" {
  description = "Backend service ID"
  value       = google_compute_backend_service.default.id
}

output "health_check_id" {
  description = "Health check ID"
  value       = google_compute_health_check.default.id
}
