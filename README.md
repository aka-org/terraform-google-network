# terraform-google-network

## Overview

This module provisions a Google Cloud VPC network, subnets, and firewall rules. It is designed to be used after creating a GCP project and enabling required APIs/service accounts (such as with the [terraform-google-project](https://github.com/aka-org/terraform-google-project) module).

---

## Table of Contents
- [Requirements](#requirements)
- [Usage](#usage)
- [Module Variables](#module-variables)
- [Outputs](#outputs)
- [APIs and Service Account Prerequisites](#apis-and-service-account-prerequisites)
- [Service Account Roles](#service-account-roles)
- [Changelog](#changelog)
- [License](#license)

---

## Requirements

- **Terraform**: >= 1.11.4
- **Provider**: hashicorp/google version 6.8.0
- **Prerequisites**:
  - A GCP project must already exist.
  - Required APIs must be enabled (Compute Engine API at minimum).
  - A service account with sufficient permissions must be available.

---

## Usage

```
module "network" {
  source  = "aka-org/network/google"
  version = "0.1.0"
  
  project_id    = var.project_id
  network_name  = "main"
  subnetworks   = [
    {
      name          = "subnet-1"
      region        = "us-central1"
      ip_cidr_range = "10.0.1.0/24"
    },
    # ... more subnets ...
  ]
  firewall_rules = [
    {
      name          = "allow-ssh"
      protocol      = "tcp"
      ports         = ["22"]
      source_ranges = ["0.0.0.0/0"]
      tags          = ["ssh"]
    },
    # ... more rules ...
  ]
}
```

---

## Module Variables

| Name                  | Description                                                                 | Type           | Default                                      |
|-----------------------|-----------------------------------------------------------------------------|----------------|----------------------------------------------|
| project_id            | The GCP project ID.                                       | string         | n/a (required)                               |
| network_name          | Name of the VPC network.                                  | string         | 'main'                                       |
| subnetworks           | List of subnetwork resources to be created.                | list(object)   | []                                          |
| firewall_rules        | List of firewall rule resources to be created.                | list(object) | []                                           |

---

## Outputs

- `network_name`: Name of the VPC.
- `network_self_link`: Self-link of the VPC.
- `subnetworks`: The created subnet resources.
- `firewall_rules`: The created firewall rule resources.

---

## APIs and Service Account Prerequisites

To apply this module, the following are required:

### APIs
- Compute Engine API (`compute.googleapis.com`)

### Service Account Roles
The service account running Terraform must have at least:
- `roles/compute.networkAdmin` (for VPC, subnet, and firewall management)
- `roles/compute.securityAdmin` (for firewall rules)
- `roles/compute.viewer` (for reading network resources)
- `roles/resourcemanager.projectIamAdmin` (if managing IAM, not strictly needed for just network resources)

---

## Changelog
See [CHANGELOG.md](CHANGELOG.md) for release history.

---

## License
Apache 2.0 - See [LICENSE](LICENSE)