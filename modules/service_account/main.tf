/******************************************
  Service Account
******************************************/
resource "google_service_account" "sa" {
  account_id   = var.account_id
  display_name = try(var.service_account.display_name, "Service account for ${var.account_id}")
  description  = try(var.service_account.description, "Managed by Terraform")
  project      = var.project_id
}

/******************************************
  IAM Roles
******************************************/
resource "google_project_iam_member" "sa_roles" {
  for_each = toset(try(var.service_account.roles, []))

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.sa.email}"
}
