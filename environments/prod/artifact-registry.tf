module "artifact_registry" {
  source = "../../modules/artifact-registry"

  project_id    = var.project_id
  region        = var.region
  repository_id = "nbp-docker"

  depends_on = [
    google_project_service.required
  ]
}

output "artifact_registry_url" {
  description = "Docker repository address"
  value       = module.artifact_registry.repository_url
}