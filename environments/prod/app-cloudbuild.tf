# Dedicated identity for application Pull Request CI.
# No access to Artifact Registry, GKE or Terraform state.

resource "google_service_account" "app_ci" {
  project      = var.project_id
  account_id   = "nbp-app-ci"
  display_name = "NBP Application CI"
  description  = "Runs Ruff, pytest and coverage checks for application PRs"
}

resource "google_project_iam_member" "app_ci_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.app_ci.email}"
}

# Terraform pipeline may assign this identity to a Cloud Build trigger.
resource "google_service_account_iam_member" "terraform_pipeline_app_ci_user" {
  service_account_id = google_service_account.app_ci.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:terraform-pipeline@nbp-devops-prod.iam.gserviceaccount.com"
}

# GitHub repository: nbp-app
resource "google_cloudbuildv2_repository" "app" {
  project           = var.project_id
  location          = var.region
  name              = "nbp-app"
  parent_connection = google_cloudbuildv2_connection.github.name
  remote_uri        = "https://github.com/tuchoz/nbp-app.git"

  lifecycle {
    prevent_destroy = true
  }
}

# Pull Request: Ruff + pytest
resource "google_cloudbuild_trigger" "app_ci" {
  project         = var.project_id
  location        = var.region
  name            = "nbp-app-ci"
  description     = "Run FastAPI quality checks on pull requests"
  service_account = google_service_account.app_ci.id
  filename        = "cloudbuild/ci.yaml"

  repository_event_config {
    repository = google_cloudbuildv2_repository.app.id

    pull_request {
      branch          = "^main$"
      comment_control = "COMMENTS_ENABLED_FOR_EXTERNAL_CONTRIBUTORS_ONLY"
    }
  }
}

# Push to main: Docker + Trivy + SBOM + Artifact Registry
resource "google_cloudbuild_trigger" "app_build" {
  project         = var.project_id
  location        = var.region
  name            = "nbp-app-build"
  description     = "Build, scan and publish NBP application container"
  service_account = google_service_account.app_builder.id
  filename        = "cloudbuild/build.yaml"

  repository_event_config {
    repository = google_cloudbuildv2_repository.app.id

    push {
      branch = "^main$"
    }
  }

  substitutions = {
    _ALLOW_TRIVY_FAILURE = "false"
  }
}