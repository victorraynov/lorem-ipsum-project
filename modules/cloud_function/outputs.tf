/******************************************
  Cloud Function Module Outputs
******************************************/
output "function_url" {
  description = "Function URL"
  value       = google_cloudfunctions2_function.function.service_config[0].uri
}

output "function_name" {
  description = "Function name"
  value       = google_cloudfunctions2_function.function.name
}
