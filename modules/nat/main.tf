# Outbound internet access for VMs without an external address: one Cloud
# Router and one Cloud NAT gateway per entry, with addresses Google
# allocates.
resource "google_compute_router" "routers" {
  for_each = { for n in var.nat_gateways : n.name => n }

  name    = coalesce(each.value.router_name, "${each.value.name}-router")
  project = var.project_id
  region  = each.value.region
  network = var.network_self_link
}

resource "google_compute_router_nat" "gateways" {
  for_each = { for n in var.nat_gateways : n.name => n }

  name    = each.value.name
  project = var.project_id
  region  = each.value.region
  router  = google_compute_router.routers[each.key].name

  nat_ip_allocate_option = "AUTO_ONLY"
  min_ports_per_vm       = each.value.min_ports_per_vm

  source_subnetwork_ip_ranges_to_nat = (
    each.value.subnetworks == null ? "ALL_SUBNETWORKS_ALL_IP_RANGES" : "LIST_OF_SUBNETWORKS"
  )

  dynamic "subnetwork" {
    for_each = each.value.subnetworks == null ? [] : each.value.subnetworks
    content {
      name                    = var.subnetwork_self_links[subnetwork.value]
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  }

  dynamic "log_config" {
    for_each = each.value.log_errors ? [1] : []
    content {
      enable = true
      filter = "ERRORS_ONLY"
    }
  }
}
