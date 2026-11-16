output "routers" {
  description = "The created Cloud Router resources"
  value       = google_compute_router.routers
}

output "nat_gateways" {
  description = "The created Cloud NAT gateway resources"
  value       = google_compute_router_nat.gateways
}
