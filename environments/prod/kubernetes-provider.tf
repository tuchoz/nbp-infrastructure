# Read connection details of the existing GKE cluster.
data "google_container_cluster" "nbp" {
  project  = var.project_id
  name     = module.gke.cluster_name
  location = var.region
}

# Use the identity running Terraform (Cloud Build service account).
data "google_client_config" "current" {}

provider "kubernetes" {
  host = "https://${data.google_container_cluster.nbp.endpoint}"

  token = data.google_client_config.current.access_token

  cluster_ca_certificate = base64decode(
    data.google_container_cluster.nbp.master_auth[0].cluster_ca_certificate
  )
}