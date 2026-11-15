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

resource "google_service_account" "terraform_plan" {
  project      = var.project_id
  account_id   = "terraform-plan"
  display_name = "Terraform Pull Request Plan"

  depends_on = [
    google_project_service.required
  ]
}

resource "google_project_iam_member" "terraform_plan_viewer" {
  project = var.project_id
  role    = "roles/viewer"

  member = "serviceAccount:${google_service_account.terraform_plan.email}"
}

resource "google_storage_bucket_iam_member" "terraform_plan_state" {
  bucket = "nbp-devops-prod-tfstate"
  role   = "roles/storage.objectViewer"

  member = "serviceAccount:${google_service_account.terraform_plan.email}"
}

resource "google_project_iam_member" "terraform_plan_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"

  member = "serviceAccount:${google_service_account.terraform_plan.email}"
}

resource "google_project_iam_custom_role" "terraform_bucket_policy_reader" {
  project     = var.project_id
  role_id     = "terraformBucketPolicyReader"
  title       = "Terraform Bucket Policy Reader"
  description = "Read bucket IAM policies during Terraform plan"

  permissions = [
    "storage.buckets.getIamPolicy"
  ]
}

resource "google_storage_bucket_iam_member" "terraform_plan_bucket_policy_reader" {
  bucket = "nbp-devops-prod-tfstate"

  role = google_project_iam_custom_role.terraform_bucket_policy_reader.name

  member = "serviceAccount:${google_service_account.terraform_plan.email}"
}