# Terraform PLAN — Pull Requests to main
resource "google_cloudbuild_trigger" "terraform_plan" {
  project     = var.project_id
  location    = var.region
  name        = "terraform-plan"
  description = "Terraform validation and plan for infrastructure pull requests"

  # Disabled until IAM and security configuration is complete.
  disabled = false

  repository_event_config {
    repository = google_cloudbuildv2_repository.infrastructure.id

    pull_request {
      branch          = "^main$"
      comment_control = "COMMENTS_ENABLED"
    }
  }

  filename = "cloudbuild/terraform-plan.yaml"

  service_account = google_service_account.terraform_plan.id
}

# Terraform APPLY — Push to main
resource "google_cloudbuild_trigger" "terraform_apply" {
  project     = var.project_id
  location    = var.region
  name        = "terraform-apply"
  description = "Apply approved Terraform changes after merge to main"

  # Disabled until deployment permissions and branch protection are ready.
  disabled = true

  repository_event_config {
    repository = google_cloudbuildv2_repository.infrastructure.id

    push {
      branch = "^main$"
    }
  }

  filename = "cloudbuild/terraform-apply.yaml"

  service_account = google_service_account.terraform_pipeline.id
}