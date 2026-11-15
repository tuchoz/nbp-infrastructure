# Dedicated service account for the NBP application build pipeline.

resource "google_service_account" "app_builder" {
  project      = var.project_id
  account_id   = "nbp-app-builder"
  display_name = "NBP Application Cloud Build"
}

# Allow application builds to push Docker images.
# Scope: nbp-docker repository only.

resource "google_artifact_registry_repository_iam_member" "app_builder_writer" {
  project    = var.project_id
  location   = var.region
  repository = module.artifact_registry.repository_id

  role = "roles/artifactregistry.writer"

  member = "serviceAccount:${google_service_account.app_builder.email}"
}

# Allow Cloud Build to write logs.

resource "google_project_iam_member" "app_builder_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"

  member = "serviceAccount:${google_service_account.app_builder.email}"
}

output "app_builder_service_account" {
  description = "Service account used by the application build pipeline"
  value       = google_service_account.app_builder.email
}