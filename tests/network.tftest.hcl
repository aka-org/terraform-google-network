# Plans the module against a mocked Google provider: no credentials, no
# API calls. Each run checks what the module would create from one set of
# inputs. Run with `terraform test` from the repository root.

mock_provider "google" {}

variables {
  project_id = "example-project"
}

run "defaults_create_only_the_network" {
  command = plan

  assert {
    condition     = output.network_name == "main"
    error_message = "The network's default name is \"main\"."
  }
  assert {
    condition     = length(output.subnetworks) == 0 && length(output.firewall_rules) == 0
    error_message = "No subnet or firewall rule is created unless asked for."
  }
  assert {
    condition     = length(output.routers) == 0 && length(output.nat_gateways) == 0
    error_message = "No router or NAT gateway is created unless asked for."
  }
}

run "subnet_as_first_released" {
  command = plan

  variables {
    subnetworks = [{
      name          = "nodes"
      region        = "europe-west1"
      ip_cidr_range = "10.0.0.0/20"
    }]
  }

  assert {
    condition     = length(output.subnetworks["nodes"].secondary_ip_range) == 0
    error_message = "A subnet without secondary_ip_ranges has none."
  }
  assert {
    condition     = output.subnetworks["nodes"].ip_cidr_range == "10.0.0.0/20"
    error_message = "The subnet carries its primary range."
  }
}

run "subnet_for_a_gke_cluster" {
  command = plan

  variables {
    subnetworks = [{
      name                     = "nodes"
      region                   = "europe-west1"
      ip_cidr_range            = "10.0.0.0/20"
      private_ip_google_access = true
      secondary_ip_ranges = [
        { range_name = "pods", ip_cidr_range = "10.4.0.0/14" },
        { range_name = "services", ip_cidr_range = "10.8.0.0/20" },
      ]
    }]
  }

  assert {
    condition     = [for r in output.subnetworks["nodes"].secondary_ip_range : r.range_name] == ["pods", "services"]
    error_message = "Secondary ranges are created in the order given."
  }
  assert {
    condition     = output.subnetworks["nodes"].private_ip_google_access == true
    error_message = "Private Google Access is switched on when asked for."
  }
}

run "nat_for_every_subnet_of_the_region" {
  command = plan

  variables {
    nat_gateways = [{ name = "egress", region = "europe-west1" }]
  }

  assert {
    condition     = output.routers["egress"].name == "egress-router"
    error_message = "The router is named after its gateway unless router_name is set."
  }
  assert {
    condition     = output.nat_gateways["egress"].source_subnetwork_ip_ranges_to_nat == "ALL_SUBNETWORKS_ALL_IP_RANGES"
    error_message = "A gateway without a subnet list serves every subnet and range of its region."
  }
  assert {
    condition     = length(output.nat_gateways["egress"].log_config) == 0
    error_message = "Logging is off unless log_errors is set."
  }
}

run "nat_for_named_subnets" {
  command = plan

  variables {
    subnetworks = [{
      name          = "nodes"
      region        = "europe-west1"
      ip_cidr_range = "10.0.0.0/20"
    }]
    nat_gateways = [{
      name        = "egress"
      region      = "europe-west1"
      router_name = "edge"
      subnetworks = ["nodes"]
      log_errors  = true
    }]
  }

  assert {
    condition     = output.routers["egress"].name == "edge"
    error_message = "router_name names the router."
  }
  assert {
    condition     = output.nat_gateways["egress"].source_subnetwork_ip_ranges_to_nat == "LIST_OF_SUBNETWORKS"
    error_message = "A gateway with a subnet list serves only those subnets."
  }
  assert {
    condition     = length(output.nat_gateways["egress"].subnetwork) == 1
    error_message = "One subnetwork block per named subnet."
  }
  assert {
    condition     = output.nat_gateways["egress"].log_config[0].filter == "ERRORS_ONLY"
    error_message = "log_errors logs translation errors only."
  }
}

run "firewall_allow_and_deny" {
  command = plan

  variables {
    firewall_rules = [
      {
        name          = "allow-ssh"
        protocol      = "tcp"
        ports         = ["22"]
        source_ranges = ["35.235.240.0/20"]
        tags          = ["bastion"]
      },
      {
        name        = "deny-from-untrusted"
        protocol    = "all"
        ports       = ["80"]
        source_tags = ["untrusted"]
        action      = "deny"
        priority    = 900
      },
    ]
  }

  assert {
    condition     = length(output.firewall_rules["allow-ssh"].allow) == 1 && length(output.firewall_rules["allow-ssh"].deny) == 0
    error_message = "A rule is an allow rule unless action says otherwise."
  }
  assert {
    condition     = one(output.firewall_rules["allow-ssh"].allow).ports == tolist(["22"])
    error_message = "An allow rule carries its ports."
  }
  assert {
    condition     = length(output.firewall_rules["deny-from-untrusted"].deny) == 1 && length(output.firewall_rules["deny-from-untrusted"].allow) == 0
    error_message = "action = \"deny\" makes a deny rule."
  }
  assert {
    condition     = length(one(output.firewall_rules["deny-from-untrusted"].deny).ports) == 0
    error_message = "Ports are dropped for a protocol that has none."
  }
  assert {
    condition     = output.firewall_rules["deny-from-untrusted"].priority == 900
    error_message = "priority is passed through."
  }
}

run "firewall_action_is_validated" {
  command = plan

  variables {
    firewall_rules = [{
      name          = "bad"
      protocol      = "tcp"
      source_ranges = ["10.0.0.0/8"]
      action        = "reject"
    }]
  }

  expect_failures = [var.firewall_rules]
}
