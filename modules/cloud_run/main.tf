/******************************************
  Service Account for Cloud Run
******************************************/
resource "google_service_account" "cloud_run_sa" {
  account_id   = "${var.service_name}-sa"
  display_name = "Service account for ${var.service_name}"
  project      = var.project_id
}

/******************************************
  Cloud Run Service
******************************************/
resource "google_cloud_run_v2_service" "service" {
  name                = var.service_name
  location            = var.region
  project             = var.project_id
  deletion_protection = false

  template {
    scaling {
      min_instance_count = try(var.service_config.min_instances, 0)
      max_instance_count = try(var.service_config.max_instances, 10)
    }

    service_account = google_service_account.cloud_run_sa.email

    containers {
      image = var.service_config.image

      resources {
        limits = {
          cpu    = try(var.service_config.cpu, "1")
          memory = try(var.service_config.memory, "512Mi")
        }
        cpu_idle = true
      }

      dynamic "env" {
        for_each = merge(
          try(var.service_config.env_vars, {}),
          {
            STORAGE_BUCKET_NAME = var.storage_bucket_name
            IMAGE_BLOB_NAME     = try(var.service_config.image_blob_name, "")
          }
        )
        content {
          name  = env.key
          value = env.value
        }
      }

      ports {
        name           = "http1"
        container_port = 8080
      }
    }

    max_instance_request_concurrency = try(var.service_config.max_concurrency, 80)
    timeout                          = try(var.service_config.timeout, "300s")
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  ingress = try(var.service_config.ingress, "INGRESS_TRAFFIC_ALL")

  labels = try(var.service_config.labels, {})

  depends_on = [google_service_account.cloud_run_sa]
}

/******************************************
  IAM - Public Access
******************************************/
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  count = try(var.service_config.allow_unauthenticated, true) ? 1 : 0

  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

/******************************************
  IAM - Storage Access for Service Account
******************************************/
resource "google_storage_bucket_iam_member" "cloud_run_storage_access" {
  for_each = try(var.service_config.storage_bucket_key, "") != "" ? toset([try(var.service_config.storage_bucket_key, "")]) : toset([])

  bucket = each.value
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.cloud_run_sa.email}"

  depends_on = [google_service_account.cloud_run_sa]
}

/******************************************
  Network Endpoint Group (for Load Balancer)
******************************************/
resource "google_compute_region_network_endpoint_group" "neg" {
  name                  = "${var.service_name}-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = google_cloud_run_v2_service.service.name
  }
}
