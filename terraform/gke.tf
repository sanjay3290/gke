
# Create the GKE cluster in the public subnet
resource "google_container_cluster" "primary" {
  name     = "my-gke-cluster"
  location = "asia-south1"
  remove_default_node_pool = true  # Remove the default node pool
  network    = google_compute_network.gke_vpc.name
  subnetwork = google_compute_subnetwork.public_subnet.name

  # Allow public IPs for the master and nodes
  private_cluster_config {
    enable_private_nodes   = false  # Allow public IPs for nodes
    enable_private_endpoint = false # Disable private endpoint for the master
    master_ipv4_cidr_block = "172.16.0.0/28"
  }

  # Enable master authorized networks for secure API access using your public IP
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "1.2.3.4/32"
      display_name = "client ip 1"
    }
    cidr_blocks {
      cidr_block   = "1.2.3.4/32"
      display_name = "client ip 2"
    }
  }

  # Disable deletion protection
  deletion_protection = false  # Allow deletion of the cluster

  # Define the master version
  min_master_version = "latest"
  initial_node_count = 1
}

# Standard node pool with autoscaling in the public subnet
resource "google_container_node_pool" "standard_nodes" {
  name       = "standard-node-pool"
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location

  # Enable autoscaling for the node pool
  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    # Ensure the nodes can have public IPs
    tags = ["public-node"]

    # Label the nodes in this node pool
    labels = {
      nodepool = "standard-node-pool"
    }

    # Metadata for disabling external legacy endpoints
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  management {
    auto_upgrade = true
    auto_repair  = true
  }
}

# Spot/Preemptible node pool with autoscaling in the public subnet
resource "google_container_node_pool" "spot_nodes" {
  name       = "spot-node-pool"
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location

  # Enable autoscaling for the spot node pool
  autoscaling {
    min_node_count = 1
    max_node_count = 4
  }

  node_config {
    machine_type    = "e2-medium"
    preemptible     = true  # Enable preemptible (spot) nodes
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    # Ensure the nodes can have public IPs
    tags = ["public-node"]

    # Label the nodes in this node pool
    labels = {
      nodepool = "spot-node-pool"
    }

    # Metadata for disabling external legacy endpoints
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  management {
    auto_upgrade = true
    auto_repair  = true
  }
}