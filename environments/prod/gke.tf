module "gke" {
  source = "../../modules/gke"

  project_id   = var.project_id
  region       = var.region
  cluster_name = "nbp-gke"

  depends_on = [
    google_project_service.required,
    google_project_iam_member.terraform_apply_roles
  ]
}

output "gke_cluster_name" {
  value = module.gke.cluster_name
}

output "gke_cluster_location" {
  value = module.gke.cluster_location
}