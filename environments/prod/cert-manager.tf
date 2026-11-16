# cert-manager manages TLS certificates for applications running on GKE.
# Installed separately from the application Helm chart.

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  repository = "oci://quay.io/jetstack/charts"
  chart      = "cert-manager"
  version    = "v1.19.6"

  set = [
    {
      name  = "crds.enabled"
      value = "true"
    },
    {
      name  = "global.leaderElection.namespace"
      value = "cert-manager"
    }
  ]

  wait    = true
  timeout = 600

  depends_on = [
    module.gke
  ]
}