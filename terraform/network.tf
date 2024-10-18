
# Create a new VPC network
resource "google_compute_network" "gke_vpc" {
  name                    = "gke-vpc"
  auto_create_subnetworks  = false  # Disable automatic subnet creation
}

# Create public subnets for the cluster in the VPC
resource "google_compute_subnetwork" "public_subnet" {
  name          = "gke-public-subnet"
  ip_cidr_range = "10.8.0.0/14"
  region        = "asia-south1"
  network       = google_compute_network.gke_vpc.name

  # No private IP Google access needed for public subnet
  private_ip_google_access = false
}

# Create a firewall rule to allow internal traffic between nodes
resource "google_compute_firewall" "gke_internal_firewall" {
  name    = "gke-internal-firewall"
  network = google_compute_network.gke_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]  # Allow all internal communication within the VPC
  }

  source_ranges = ["10.8.0.0/14"]  # Internal traffic within the subnet
  direction     = "INGRESS"
}

# Allow egress traffic to the internet for pulling container images
resource "google_compute_firewall" "gke_egress_firewall" {
  name    = "gke-egress-firewall"
  network = google_compute_network.gke_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["443"]  # Allow HTTPS traffic for container image pulls
  }

  destination_ranges = ["0.0.0.0/0"]  # Allow traffic to public internet
  direction          = "EGRESS"
}