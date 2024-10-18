# Output the static IP address
output "ingress_static_ip_address" {
  value = google_compute_global_address.ingress_static_ip.address
  description = "The global static IP address for the GKE ingress"
}