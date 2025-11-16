/******************************************
  Cloud Storage Bucket
******************************************/
resource "google_storage_bucket" "bucket" {
  name          = var.bucket_name
  location      = var.location
  storage_class = try(var.bucket.storage_class, "STANDARD")
  project       = var.project_id

  force_destroy = try(var.bucket.force_destroy, false)

  uniform_bucket_level_access = try(var.bucket.uniform_bucket_level_access, true)

  dynamic "versioning" {
    for_each = try(var.bucket.versioning, false) ? [1] : []
    content {
      enabled = true
    }
  }

  labels = try(var.bucket.labels, {})
}
