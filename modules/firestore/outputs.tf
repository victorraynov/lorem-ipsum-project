/******************************************
  Firestore Module Outputs
******************************************/
output "database_name" {
  description = "Database name"
  value       = google_firestore_database.database.name
}

output "database_id" {
  description = "Database ID"
  value       = google_firestore_database.database.id
}
