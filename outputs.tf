/******************************************
  Cloud Run Outputs
******************************************/
output "cloud_run_urls" {
  description = "Cloud Run service URLs"
  value = {
    for k, v in module.cloud_run : k => v.service_url
  }
}

output "cloud_run_service_accounts" {
  description = "Cloud Run service account emails"
  value = {
    for k, v in module.cloud_run : k => v.service_account
  }
}

/******************************************
  Artifact Registry Outputs
******************************************/
output "artifact_registry_urls" {
  description = "Artifact Registry repository URLs"
  value = {
    for k, v in module.artifact_registry : k => v.repository_url
  }
}

/******************************************
  Storage Outputs
******************************************/
output "storage_bucket_names" {
  description = "Cloud Storage bucket names"
  value = {
    for k, v in module.storage : k => v.bucket_name
  }
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
  SSL Certificate Outputs
******************************************/
output "ssl_certificates" {
  description = "SSL certificate names"
  value = {
    for k, v in module.ssl : k => v.cert_name
  }
}
