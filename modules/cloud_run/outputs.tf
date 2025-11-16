/******************************************
  Cloud Run Module Outputs
******************************************/
output "service_urls" {
  description = "Map of Cloud Run service URLs"
  value = {
    for k, v in google_cloud_run_v2_service.service : k => v.uri
  }
}

output "service_names" {
  description = "Map of Cloud Run service names"
  value = {
    for k, v in google_cloud_run_v2_service.service : k => v.name
  }
}

output "neg_ids" {
  description = "Map of Network Endpoint Group IDs"
  value = {
    for k, v in google_compute_region_network_endpoint_group.neg : k => v.id
  }
}

output "service_account_emails" {
  description = "Map of service account emails"
  value = {
    for k, v in google_service_account.cloud_run_sa : k => v.email
  }
}