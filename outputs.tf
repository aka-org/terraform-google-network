output "network_name" {
  description = "Name of the vpc network"
  value       = module.vpc.network_name
}

output "network_self_link" {
  description = "Self link to the vpc network"
  value       = module.vpc.network_self_link
}

output "firewall_rules" {
  description = "The created firewall rule resources"
  value       = module.firewall_rules.firewall_rules
}

output "subnetworks" {
  description = "The created subnetwork resources"
  value       = module.subnets.subnetworks
}

output "routers" {
  description = "The created Cloud Router resources"
  value       = module.nat.routers
}

output "nat_gateways" {
  description = "The created Cloud NAT gateway resources"
  value       = module.nat.nat_gateways
}
