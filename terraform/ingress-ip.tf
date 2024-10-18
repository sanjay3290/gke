# Allocate a global static IP for use with the ingress
resource "google_compute_global_address" "ingress_static_ip" {
  name = "gke-ingress-static-ip"
}