# Dedicated identity for deploying the NBP application to GKE.
resource "google_service_account" "nbp_deployer" {
  project      = var.project_id
  account_id   = "nbp-deployer"
  display_name = "NBP GKE Application Deployer"
  description  = "Deploys the approved NBP application image using Helm"
}

# Required for Cloud Build logs.
resource "google_project_iam_member" "nbp_deployer_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"

  member = "serviceAccount:${google_service_account.nbp_deployer.email}"
}

# Required for Kubernetes application deployment.
resource "google_project_iam_member" "nbp_deployer_gke" {
  project = var.project_id
  role    = "roles/container.clusterViewer"

  member = "serviceAccount:${google_service_account.nbp_deployer.email}"
}

# Allow Terraform pipeline to assign the deployer to a Cloud Build trigger.
resource "google_service_account_iam_member" "terraform_pipeline_deployer_user" {
  service_account_id = google_service_account.nbp_deployer.name
  role               = "roles/iam.serviceAccountUser"

  member = "serviceAccount:${google_service_account.terraform_pipeline.email}"
}