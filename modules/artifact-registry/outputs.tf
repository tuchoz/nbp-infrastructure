output "repository_id" {
  description = "Artifact Registry repository ID"
  value       = google_artifact_registry_repository.docker.repository_id
}

output "repository_url" {
  description = "Docker repository URL"
  value       = google_artifact_registry_repository.docker.registry_uri
}