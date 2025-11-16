/******************************************
  Enable Required APIs
******************************************/
resource "google_project_service" "required_apis" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "storage.googleapis.com",
    "iam.googleapis.com",
  ])

  service            = each.value
  disable_on_destroy = false
}

/******************************************
  Artifact Registry Module
******************************************/
module "artifact_registry" {
  source = "./modules/artifact_registry"

  for_each = var.enabled_modules.artifact_registry ? var.artifact_repositories : {}

  project_id    = var.project_id
  location      = var.region
  repository_id = each.key
  repository    = each.value

  depends_on = [google_project_service.required_apis]
}

/******************************************
  Cloud Storage Module
******************************************/
module "storage" {
  source = "./modules/storage"

  for_each = var.enabled_modules.storage ? var.storage_buckets : {}

  project_id  = var.project_id
  location    = try(each.value.location, var.storage_location)
  bucket_name = each.key
  bucket      = each.value

  depends_on = [google_project_service.required_apis]
}

/******************************************
  Cloud Run Module
******************************************/
module "cloud_run" {
  source = "./modules/cloud_run"

  count = var.enabled_modules.cloud_run ? 1 : 0

  project_id         = var.project_id
  region             = var.primary_region
  cloud_run_services = var.cloud_run_services

  depends_on = [
    google_project_service.required_apis,
    module.storage
  ]
}

/******************************************
/******************************************
  Cloud Run Module - Failover Region
******************************************/
module "cloud_run_failover" {
  source = "./modules/cloud_run"

  count = var.enabled_modules.cloud_run && var.failover_enabled ? 1 : 0

  project_id         = var.project_id
  region             = var.failover_region
  cloud_run_services = var.cloud_run_services

  depends_on = [
    google_project_service.required_apis,
    module.storage
  ]
}

/******************************************
  SSL Certificate (Managed)
******************************************/
module "ssl" {
  source = "./modules/ssl"

  for_each = var.enabled_modules.ssl ? var.ssl_certificates : {}

  project_id  = var.project_id
  cert_name   = each.key
  cert_config = each.value

  depends_on = [google_project_service.required_apis]
}

/******************************************
  Global Load Balancer Module
******************************************/
module "load_balancer" {
  source = "./modules/load_balancer"

  for_each = var.enabled_modules.load_balancer && var.failover_enabled ? var.load_balancers : {}

  project_id = var.project_id
  lb_name    = each.key
  lb_config  = each.value

  primary_neg    = module.cloud_run[0].neg_ids[each.value.service_key]
  primary_region = var.primary_region

  failover_neg    = module.cloud_run_failover[0].neg_ids[each.value.service_key]
  failover_region = var.failover_region

  ssl_cert_id = try(module.ssl[each.value.ssl_cert_key].cert_id, null)

  depends_on = [
    module.cloud_run,
    module.cloud_run_failover,
    module.ssl
  ]
}
