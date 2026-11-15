resource "google_cloudbuildv2_connection" "github" {
  project  = var.project_id
  location = var.region
  name     = "github-connection"

  github_config {
    app_installation_id = 182304023

    authorizer_credential {
      oauth_token_secret_version = "projects/nbp-devops-prod/locations/europe-central2/secrets/github-connection-github-oauthtoken-18ff9d/versions/latest"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_cloudbuildv2_repository" "infrastructure" {
  project           = var.project_id
  location          = var.region
  name              = "nbp-infrastructure"
  parent_connection = google_cloudbuildv2_connection.github.name
  remote_uri        = "https://github.com/tuchoz/nbp-infrastructure.git"

  lifecycle {
    prevent_destroy = true
  }
}