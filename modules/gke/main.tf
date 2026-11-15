resource "google_container_cluster" "this" {
  project  = var.project_id
  name     = var.cluster_name
  location = var.region

  enable_autopilot    = true
  deletion_protection = true

  release_channel {
    channel = "REGULAR"
  }

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {}

  resource_labels = {
    application = "nbp"
    managed_by  = "terraform"
  }
}