resource "google_compute_subnetwork" "subnetworks" {
  for_each = { for s in var.subnetworks : s.name => s }

  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
  project       = var.project_id
  region        = each.value.region
  network       = var.network_self_link

  private_ip_google_access = each.value.private_ip_google_access

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}
