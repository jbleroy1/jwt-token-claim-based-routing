resource "google_project_service" "apis" {
  for_each = toset([
    # Note that appengine is required for both GAE and Cloud Tasks.
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "cloudtrace.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "stackdriver.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "gkehub.googleapis.com",
    "multiclusteringress.googleapis.com",
    "multiclusterservicediscovery.googleapis.com",
    "meshconfig.googleapis.com",
    "mesh.googleapis.com",
    "trafficdirector.googleapis.com",
    "dns.googleapis.com"
  ])
  project = var.project_id
  service = each.value

}
