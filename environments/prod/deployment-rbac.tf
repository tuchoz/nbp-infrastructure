# Namespace nbp-prod already exists.
# It is not created or imported by Terraform.

resource "kubernetes_role_v1" "nbp_deployer" {
  metadata {
    name      = "nbp-deployer"
    namespace = "nbp-prod"
  }

  # Helm v3 stores release metadata in Kubernetes Secrets.
  # The deployer also needs to manage application Services.
  rule {
    api_groups = [""]
    resources = [
      "secrets",
      "configmaps",
      "services"
    ]
    verbs = [
      "get",
      "list",
      "watch",
      "create",
      "update",
      "patch",
      "delete"
    ]
  }

  # Helm --wait needs to inspect Pods.
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }

  # Application Deployment.
  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs = [
      "get",
      "list",
      "watch",
      "create",
      "update",
      "patch",
      "delete"
    ]
  }

  # Helm needs to inspect ReplicaSets during deployment.
  rule {
    api_groups = ["apps"]
    resources  = ["replicasets"]
    verbs      = ["get", "list", "watch"]
  }

  # GKE Ingress.
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs = [
      "get",
      "list",
      "watch",
      "create",
      "update",
      "patch",
      "delete"
    ]
  }

  # Horizontal Pod Autoscaler.
  rule {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs = [
      "get",
      "list",
      "watch",
      "create",
      "update",
      "patch",
      "delete"
    ]
  }

  # Allow Helm CD to manage namespaced Let's Encrypt Issuers.
  rule {
    api_groups = ["cert-manager.io"]
    resources  = ["issuers", "certificates"]
    verbs = [
      "get",
      "list",
      "watch",
      "create",
      "update",
      "patch",
      "delete"
    ]
  }
}

resource "kubernetes_role_binding_v1" "nbp_deployer" {
  metadata {
    name      = "nbp-deployer"
    namespace = "nbp-prod"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.nbp_deployer.metadata[0].name
  }

  subject {
    kind      = "User"
    name      = google_service_account.nbp_deployer.email
    api_group = "rbac.authorization.k8s.io"
  }
}