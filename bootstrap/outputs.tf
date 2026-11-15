output "terraform_state_bucket" {
  description = "GCS bucket used for Terraform remote state"
  value       = google_storage_bucket.terraform_state.name
}

output "terraform_state_location" {
  description = "Location of Terraform state bucket"
  value       = google_storage_bucket.terraform_state.location
}