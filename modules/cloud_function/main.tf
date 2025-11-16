/******************************************
  Cloud Function (Gen 2)
******************************************/

data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = try(var.function_config.source_dir, "../function")
  output_path = "/tmp/${var.function_name}.zip"
}

resource "google_storage_bucket" "function_bucket" {
  name          = "${var.project_id}-${var.function_name}-source"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "function_archive" {
  name   = "${var.function_name}-${data.archive_file.function_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = data.archive_file.function_zip.output_path
}

resource "google_cloudfunctions2_function" "function" {
  name        = var.function_name
  location    = var.region
  description = try(var.function_config.description, "VPC Inventory Function")

  build_config {
    runtime     = try(var.function_config.runtime, "python311")
    entry_point = try(var.function_config.entry_point, "vpc_inventory")
    
    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.function_archive.name
      }
    }
  }

  service_config {
    available_memory   = try(var.function_config.available_memory, "512M")
    timeout_seconds    = try(var.function_config.timeout, 540)
    max_instance_count = try(var.function_config.max_instances, 10)
    min_instance_count = try(var.function_config.min_instances, 0)
    
    service_account_email = var.service_account
    
    ingress_settings = try(var.function_config.ingress_settings, "ALLOW_ALL")
    
    environment_variables = merge(
      try(var.function_config.environment_variables, {}),
      {
        GCP_PROJECT = var.project_id
      }
    )
  }
}

/******************************************
  IAM - Allow Unauthenticated Invocations
******************************************/
resource "google_cloud_run_service_iam_member" "invoker" {
  project  = var.project_id
  location = var.region
  service  = google_cloudfunctions2_function.function.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
