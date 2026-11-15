resource "google_artifact_registry_repository" "docker" {
  project       = var.project_id
  location      = var.region
  repository_id = var.repository_id
  description   = "Docker images for NBP USD/PLN application"
  format        = "DOCKER"

  docker_config {
    immutable_tags = true
  }

  labels = {
    application = "nbp"
    environment = "prod"
    managed_by  = "terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}