/******************************************
  Service Accounts for Cloud Run
******************************************/
resource "google_service_account" "cloud_run_sa" {
  for_each = var.cloud_run_services

  account_id   = "${each.key}-sa"
  display_name = "Service account for ${each.key}"
  project      = var.project_id
}

/******************************************
  Cloud Run Services
******************************************/
resource "google_cloud_run_v2_service" "service" {
  for_each = var.cloud_run_services

  name                = each.key
  location            = var.region
  project             = var.project_id
  deletion_protection = false
  ingress             = try(each.value.ingress, "INGRESS_TRAFFIC_ALL")

  template {
    scaling {
      min_instance_count = try(each.value.min_instances, 0)
      max_instance_count = try(each.value.max_instances, 10)
    }

    service_account = google_service_account.cloud_run_sa[each.key].email
    timeout         = try(each.value.timeout, "300s")

    containers {
      image = each.value.image

      ports {
        name           = try(each.value.ports.name, "http1")
        container_port = try(each.value.ports.container_port, 8080)
      }

      resources {
        limits = {
          cpu    = try(each.value.cpu, "1")
          memory = try(each.value.memory, "512Mi")
        }
        cpu_idle = true
      }

      dynamic "env" {
        for_each = try(each.value.env_vars, {})
        content {
          name  = env.key
          value = env.value
        }
      }
    }

    max_instance_request_concurrency = try(each.value.max_concurrency, 80)
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  labels = try(each.value.labels, {})

  depends_on = [google_service_account.cloud_run_sa]
}

/******************************************
  IAM - Public Access
******************************************/
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  for_each = {
    for k, v in var.cloud_run_services : k => v
    if try(v.allow_unauthenticated, true)
  }

  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.service[each.key].name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

/******************************************
  IAM - Storage Access for Service Accounts
******************************************/
resource "google_storage_bucket_iam_member" "cloud_run_storage_access" {
  for_each = {
    for pair in flatten([
      for service_key, service_config in var.cloud_run_services : [
        for bucket_key in coalesce(service_config.storage_buckets, []) : {
          key         = "${service_key}-${bucket_key}"
          service_key = service_key
          bucket_key  = bucket_key
        }
      ]
    ]) : pair.key => pair
  }

  bucket = each.value.bucket_key
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.cloud_run_sa[each.value.service_key].email}"

  depends_on = [google_service_account.cloud_run_sa]
}

/******************************************
  Network Endpoint Groups (for Load Balancer)
******************************************/
resource "google_compute_region_network_endpoint_group" "neg" {
  for_each = var.cloud_run_services

  name                  = "${each.key}-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = google_cloud_run_v2_service.service[each.key].name
  }
}