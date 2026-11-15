resource "google_service_account" "terraform_pipeline" {
  project      = var.project_id
  account_id   = "terraform-pipeline"
  display_name = "Terraform Infrastructure Pipeline"

  depends_on = [
    google_project_service.required
  ]
}

resource "google_storage_bucket_iam_member" "terraform_state_access" {
  bucket = "nbp-devops-prod-tfstate"
  role   = "roles/storage.objectAdmin"

  member = "serviceAccount:${google_service_account.terraform_pipeline.email}"
}

resource "google_project_iam_member" "terraform_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"

  member = "serviceAccount:${google_service_account.terraform_pipeline.email}"
}