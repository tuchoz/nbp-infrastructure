# Helm uses the same GKE cluster and Cloud Build identity
# as the Kubernetes provider.

provider "helm" {
  kubernetes = {
    host = "https://${data.google_container_cluster.nbp.endpoint}"

    token = data.google_client_config.current.access_token

    cluster_ca_certificate = base64decode(
      data.google_container_cluster.nbp.master_auth[0].cluster_ca_certificate
    )
  }
}