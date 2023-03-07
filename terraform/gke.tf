# GKE cluster
resource "google_container_cluster" "primary" {
  provider = google-beta
  project  = var.project_id
  depends_on = [
    google_compute_subnetwork.subnet
  ]
  count                     = length(var.regions)
  name                      = "${var.regions[count.index]}-gke"
  location                  = var.regions[count.index]
  remove_default_node_pool  = false
  initial_node_count        = 2
  network                   = google_compute_network.vpc.name
  subnetwork                = google_compute_subnetwork.subnet[count.index].name
  default_max_pods_per_node = 32
  resource_labels = {
    mesh_id = "proj-${var.project_number}"
  }
  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS", "APISERVER", "CONTROLLER_MANAGER", "SCHEDULER"]

    managed_prometheus {
      enabled = true
    }
  }
  release_channel {
    channel = "REGULAR"
  }
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    machine_type = "e2-standard-8"
    labels = {
      region  = var.regions[count.index],
      mesh_id = "proj-${var.project_number}"
    }

    tags = [
      var.regions[count.index]
    ]

  }
  networking_mode = "VPC_NATIVE"
  addons_config {
    config_connector_config {
      enabled = true
    }
  }
  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-ranges-${count.index}"
    services_secondary_range_name = "services-range-${count.index}"
  }
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

}


resource "google_gke_hub_membership" "membership" {
  project = var.project_id
  depends_on = [
    google_container_cluster.primary, google_project_service.apis
  ]
  provider      = google-beta
  count         = length(var.regions)
  membership_id = "mc-member-${count.index}"
  endpoint {
    gke_cluster {
      resource_link = google_container_cluster.primary[count.index].id
    }

  }
  authority {
    issuer = "https://container.googleapis.com/v1/${google_container_cluster.primary[count.index].id}"
  }
}
resource "google_gke_hub_feature" "feature" {
  project = var.project_id
  depends_on = [
    google_container_cluster.primary, google_gke_hub_membership.membership, google_project_service.apis
  ]
  name     = "multiclusteringress"
  location = "global"
  spec {
    multiclusteringress {
      config_membership = google_gke_hub_membership.membership[0].id
    }
  }
  provider = google-beta
}
resource "google_gke_hub_feature" "feature_asm" {
  project = var.project_id
  depends_on = [
    google_container_cluster.primary, google_gke_hub_membership.membership, google_project_service.apis
  ]
  provider = google-beta

  name     = "servicemesh"
  location = "global"
}


resource "google_gke_hub_feature_membership" "feature_member_mesh" {
  location   = "global"
  project    = var.project_id
  count      = length(var.regions)
  feature    = google_gke_hub_feature.feature_asm.name
  membership = google_gke_hub_membership.membership[count.index].membership_id

  mesh {
    management = "MANAGEMENT_AUTOMATIC"
  }
  provider = google-beta

}


