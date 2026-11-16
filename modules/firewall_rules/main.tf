locals {
  # Firewall Rules
  no_ports_protocols = ["icmp", "esp", "ah", "all", "sctp", "ipip"]
}

resource "google_compute_firewall" "rules" {
  for_each = { for rule in var.firewall_rules : rule.name => rule }

  name     = each.value.name
  project  = var.project_id
  network  = var.network_self_link
  priority = each.value.priority

  dynamic "allow" {
    for_each = each.value.action == "allow" ? [1] : []
    content {
      protocol = each.value.protocol
      # Check if specified protocol allows to specify ports
      ports = contains(local.no_ports_protocols, each.value.protocol) ? [] : each.value.ports
    }
  }

  dynamic "deny" {
    for_each = each.value.action == "deny" ? [1] : []
    content {
      protocol = each.value.protocol
      ports    = contains(local.no_ports_protocols, each.value.protocol) ? [] : each.value.ports
    }
  }

  source_ranges = each.value.source_ranges
  source_tags   = each.value.source_tags

  target_tags = each.value.tags
}
