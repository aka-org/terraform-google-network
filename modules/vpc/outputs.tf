output "network_name" {
  description = "Name of the vpc network"
  value       = google_compute_network.vpc.name
}

output "network_self_link" {
  description = "Self link of the vpc network"
  value       = google_compute_network.vpc.self_link
}