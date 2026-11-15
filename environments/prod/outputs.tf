output "terraform_pipeline_service_account" {
  description = "Service account used by the infrastructure pipeline"
  value       = google_service_account.terraform_pipeline.email
}