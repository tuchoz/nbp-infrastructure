# GitHub repository containing the Helm chart and deployment pipeline.
resource "google_cloudbuildv2_repository" "deployment" {
  project           = var.project_id
  location          = var.region
  name              = "nbp-deployment"
  parent_connection = google_cloudbuildv2_connection.github.name
  remote_uri        = "https://github.com/tuchoz/nbp-deployment.git"

  lifecycle {
    prevent_destroy = true
  }
}

# Deploy approved application digest to GKE after merging to main.
resource "google_cloudbuild_trigger" "deployment_cd" {
  project     = var.project_id
  location    = var.region
  name        = "nbp-deployment-cd"
  description = "Deploy operator-approved NBP image to GKE using Helm"

  service_account = google_service_account.nbp_deployer.id
  filename        = "cloudbuild/deploy.yaml"

  repository_event_config {
    repository = google_cloudbuildv2_repository.deployment.id

    push {
      branch = "^main$"
    }
  }

  depends_on = [
    google_service_account_iam_member.terraform_pipeline_deployer_user,
    google_project_iam_member.nbp_deployer_gke,
    google_project_iam_member.nbp_deployer_logging
  ]
}