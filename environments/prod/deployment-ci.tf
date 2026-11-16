# Dedicated service account for Helm PR validation.
# No permissions to deploy to GKE.

resource "google_service_account" "nbp_deployment_ci" {
  project      = var.project_id
  account_id   = "nbp-deployment-ci"
  display_name = "NBP Deployment PR CI"
  description  = "Validates Helm charts without deploying"
}

resource "google_project_iam_member" "nbp_deployment_ci_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.nbp_deployment_ci.email}"
}

# Terraform pipeline needs permission to assign the CI service account
# to the Cloud Build trigger.
resource "google_service_account_iam_member" "terraform_pipeline_deployment_ci_user" {
  service_account_id = google_service_account.nbp_deployment_ci.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.terraform_pipeline.email}"
}

resource "google_cloudbuild_trigger" "deployment_ci" {
  project         = var.project_id
  location        = var.region
  name            = "nbp-deployment-ci"
  description     = "Validate Helm chart on pull requests"
  service_account = google_service_account.nbp_deployment_ci.id

  filename = "cloudbuild/ci.yaml"

  repository_event_config {
    repository = google_cloudbuildv2_repository.deployment.id

    pull_request {
      branch          = "^main$"
      comment_control = "COMMENTS_ENABLED_FOR_EXTERNAL_CONTRIBUTORS_ONLY"
    }
  }

  depends_on = [
    google_service_account_iam_member.terraform_pipeline_deployment_ci_user,
    google_project_iam_member.nbp_deployment_ci_logging
  ]
}