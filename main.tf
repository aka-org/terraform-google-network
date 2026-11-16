module "vpc" {
  source       = "./modules/vpc"
  project_id   = var.project_id
  network_name = var.network_name
}

module "subnets" {
  source            = "./modules/subnets"
  project_id        = var.project_id
  network_self_link = module.vpc.network_self_link
  subnetworks       = var.subnetworks
}

module "firewall_rules" {
  source            = "./modules/firewall_rules"
  project_id        = var.project_id
  network_self_link = module.vpc.network_self_link
  firewall_rules    = var.firewall_rules
}

module "nat" {
  source            = "./modules/nat"
  project_id        = var.project_id
  network_self_link = module.vpc.network_self_link
  nat_gateways      = var.nat_gateways

  subnetwork_self_links = { for name, s in module.subnets.subnetworks : name => s.self_link }
}
