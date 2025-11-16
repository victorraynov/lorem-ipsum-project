/******************************************
  Artifact Registry Module Outputs
******************************************/
output "repository_id" {
  description = "Repository ID"
  value       = google_artifact_registry_repository.repo.id
}

output "repository_url" {
  description = "Docker repository URL"
  value       = "${var.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}"
}
