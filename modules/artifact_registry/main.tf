/******************************************
  Artifact Registry Repository
******************************************/
resource "google_artifact_registry_repository" "repo" {
  location      = var.location
  repository_id = var.repository_id
  description   = try(var.repository.description, "Docker repository managed by Terraform")
  format        = "DOCKER"

  labels = try(var.repository.labels, {})
}
