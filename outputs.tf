/******************************************
  Cloud Run Outputs
******************************************/
output "cloud_run_primary_urls" {
  description = "Primary region Cloud Run URLs"
  value       = try(module.cloud_run[0].service_urls, {})
}

output "cloud_run_failover_urls" {
  description = "Failover region Cloud Run URLs (if failover_enabled = true)"
  value       = var.failover_enabled ? try(module.cloud_run_failover[0].service_urls, {}) : {}
}

output "cloud_run_service_accounts" {
  description = "Service account emails"
  value       = try(module.cloud_run[0].service_account_emails, {})
}

/******************************************
  Load Balancer Outputs
******************************************/
output "load_balancer_ip" {
  description = "Global Load Balancer IP address"
  value = {
    for k, v in module.load_balancer : k => v.lb_ip
  }
}

output "load_balancer_url" {
  description = "Load Balancer URL"
  value = {
    for k, v in module.load_balancer : k => "http://${v.lb_ip}"
  }
}

/******************************************
  Storage Outputs
******************************************/
output "storage_bucket_urls" {
  description = "Storage bucket URLs"
  value = {
    for k, v in module.storage : k => v.bucket_url
  }
}

/******************************************
  SSL Certificate Outputs
******************************************/
output "ssl_certificates" {
  description = "SSL certificate names"
  value = {
    for k, v in module.ssl : k => v.cert_name
  }
}

/******************************************
  Artifact Registry Outputs
******************************************/
output "artifact_registry_urls" {
  description = "Artifact Registry repository URLs"
  value = {
    for k, v in try(module.artifact_registry, {}) : k => try(v.repository_url, "")
  }
}