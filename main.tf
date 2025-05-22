module "vpc" {
  source     = "./modules/vpc"
  project_id = var.project_id
  network_name   = var.network_name
}

module "subnets" {
  source      = "./modules/subnets"
  project_id  = var.project_id
  network_self_link = module.vpc.network_self_link
  subnetworks = var.subnetworks
}

module "firewall_rules" {
  source         = "./modules/firewall_rules"
  project_id = var.project_id
  network_self_link = module.vpc.network_self_link
  firewall_rules = var.firewall_rules
}