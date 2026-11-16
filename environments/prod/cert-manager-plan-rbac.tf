# Allow the Terraform PLAN identity to inspect Helm release metadata
# stored as Kubernetes Secrets in the cert-manager namespace.

resource "kubernetes_role_v1" "cert_manager_plan_reader" {
  metadata {
    name      = "terraform-plan-helm-reader"
    namespace = "cert-manager"
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_role_binding_v1" "cert_manager_plan_reader" {
  metadata {
    name      = "terraform-plan-helm-reader"
    namespace = "cert-manager"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.cert_manager_plan_reader.metadata[0].name
  }

  subject {
    kind      = "User"
    name      = google_service_account.terraform_plan.email
    api_group = "rbac.authorization.k8s.io"
  }
}