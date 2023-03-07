provider "google" {
  project = var.project_id
}

# VPC
resource "google_compute_network" "vpc" {
  depends_on = [
    google_project_service.apis
  ]
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet for each gke cluster
resource "google_compute_subnetwork" "subnet" {
  depends_on = [
    google_compute_network.vpc
  ]
  count         = length(var.regions)
  name          = "${var.project_id}-${var.regions[count.index]}-subnet"
  region        = var.regions[count.index]
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.${count.index}.0/24"
  secondary_ip_range {
    range_name    = "services-range-${count.index}"
    ip_cidr_range = "192.168.${count.index}.0/24"
  }

  secondary_ip_range {
    range_name    = "pod-ranges-${count.index}"
    ip_cidr_range = "192.168.${4 * count.index + 64}.0/22"
  }
}

