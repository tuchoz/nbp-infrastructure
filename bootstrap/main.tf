resource "google_project_service" "storage" {
  project = var.project_id
  service = "storage.googleapis.com"

  disable_on_destroy = false
}

resource "google_storage_bucket" "terraform_state" {
  name     = "${var.project_id}-tfstate"
  project  = var.project_id
  location = "EU"

  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    google_project_service.storage
  ]
}