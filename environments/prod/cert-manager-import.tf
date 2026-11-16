# Adopt the existing cert-manager Helm release after its initial
# installation failed during the GKE Autopilot leader election check.

import {
  to = helm_release.cert_manager
  id = "cert-manager/cert-manager"
}