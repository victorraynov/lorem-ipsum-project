/******************************************
  Firestore Database
******************************************/
resource "google_firestore_database" "database" {
  project     = var.project_id
  name        = var.database_name
  location_id = var.location
  type        = try(var.database.type, "FIRESTORE_NATIVE")

  concurrency_mode            = try(var.database.concurrency_mode, "OPTIMISTIC")
  app_engine_integration_mode = try(var.database.app_engine_integration_mode, "DISABLED")
}
