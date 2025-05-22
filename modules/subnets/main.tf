resource "google_compute_subnetwork" "subnetworks" {
  for_each = { for s in var.subnetworks : s.name => s }

  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
  project       = var.project_id
  region        = each.value.region
  network       = var.network_self_link
}