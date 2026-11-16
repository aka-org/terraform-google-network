# terraform-google-network

## Overview

This module provisions a Google Cloud VPC network, subnets (with secondary ranges), firewall rules, and Cloud NAT gateways. It is designed to be used after creating a GCP project and enabling required APIs/service accounts (such as with the [terraform-google-project](https://github.com/aka-org/terraform-google-project) module).

---

## Table of Contents
- [Requirements](#requirements)
- [Usage](#usage)
- [Inputs and outputs](#inputs-and-outputs)
- [APIs and Service Account Prerequisites](#apis-and-service-account-prerequisites)
- [Development](#development)
- [Changelog](#changelog)
- [License](#license)

---

## Requirements

- **Terraform**: >= 1.11.4
- **Provider**: hashicorp/google >= 6.8, < 8 (checked on 6.8.0 and the latest 7.x)
- **Prerequisites**:
  - A GCP project must already exist.
  - Required APIs must be enabled (Compute Engine API at minimum).
  - A service account with sufficient permissions must be available.

---

## Usage

```
module "network" {
  source  = "aka-org/network/google"
  version = "0.2.0"

  project_id    = var.project_id
  network_name  = "main"
  subnetworks   = [
    {
      name          = "subnet-1"
      region        = "us-central1"
      ip_cidr_range = "10.0.1.0/24"
    },
    {
      # A subnet for a VPC-native GKE cluster with private nodes
      name                     = "gke"
      region                   = "europe-west1"
      ip_cidr_range            = "10.10.0.0/20"
      private_ip_google_access = true
      secondary_ip_ranges = [
        { range_name = "pods", ip_cidr_range = "10.20.0.0/16" },
        { range_name = "services", ip_cidr_range = "10.30.0.0/20" },
      ]
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
    {
      name        = "web-to-api"
      protocol    = "tcp"
      ports       = ["8080"]
      source_tags = ["web"]
      tags        = ["api"]
    },
    {
      name          = "deny-everything-else"
      protocol      = "all"
      action        = "deny"
      priority      = 65000
      source_ranges = ["0.0.0.0/0"]
    },
    # ... more rules ...
  ]
  nat_gateways = [
    { name = "nat", region = "europe-west1" },
  ]
}
```

---

## Inputs and outputs

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| project\_id | The id of the host project | `string` | n/a | yes |
| firewall\_rules | List of firewall rule resources to be created | <pre>list(object({<br/>    name     = string<br/>    protocol = string<br/>    # Ignored for protocols without ports (icmp, esp, ah, sctp, ipip, all).<br/>    ports = optional(list(string), [])<br/>    # Where the traffic comes from: address ranges, or instances carrying<br/>    # one of the source tags (at least one of the two).<br/>    source_ranges = optional(list(string))<br/>    source_tags   = optional(list(string))<br/>    # The instances the rule applies to; unset applies it to every<br/>    # instance in the network.<br/>    tags = optional(list(string))<br/>    # "allow" or "deny".<br/>    action = optional(string, "allow")<br/>    # 0 (first) to 65535; unset leaves the provider's default (1000).<br/>    priority = optional(number)<br/>  }))</pre> | `[]` | no |
| nat\_gateways | List of Cloud NAT gateways to be created, each with its own Cloud Router | <pre>list(object({<br/>    name   = string<br/>    region = string<br/>    # The Cloud Router the gateway hangs on; unset names it "<name>-router".<br/>    router_name = optional(string)<br/>    # The subnets served: unset serves every subnet of the region, with<br/>    # all its ranges (secondary ones included, so GKE pods too); else the<br/>    # names of subnets created by this module.<br/>    subnetworks = optional(list(string))<br/>    # Ports reserved per VM; unset leaves the provider's default.<br/>    min_ports_per_vm = optional(number)<br/>    # Logs translation errors to Cloud Logging.<br/>    log_errors = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| network\_name | The name of the vpc network | `string` | `"main"` | no |
| subnetworks | List of subnetwork resources to be created | <pre>list(object({<br/>    name          = string<br/>    region        = string<br/>    ip_cidr_range = string<br/>    # Named secondary ranges (GKE's pods and services ranges).<br/>    secondary_ip_ranges = optional(list(object({<br/>      range_name    = string<br/>      ip_cidr_range = string<br/>    })), [])<br/>    # Lets VMs without an external address reach Google APIs. Unset<br/>    # leaves the provider's default (off).<br/>    private_ip_google_access = optional(bool)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| firewall\_rules | The created firewall rule resources |
| nat\_gateways | The created Cloud NAT gateway resources |
| network\_name | Name of the vpc network |
| network\_self\_link | Self link to the vpc network |
| routers | The created Cloud Router resources |
| subnetworks | The created subnetwork resources |
<!-- END_TF_DOCS -->

---

## Fields of the list variables

### `subnetworks` fields

| Field | Description | Type | Default |
|---|---|---|---|
| name | Name of the subnet; also its key in the `subnetworks` output, so names must be unique across regions. | string | required |
| region | Region of the subnet. | string | required |
| ip_cidr_range | Primary range. | string | required |
| secondary_ip_ranges | Named secondary ranges, each `{ range_name, ip_cidr_range }` (a GKE cluster's pods and services). | list(object) | `[]` |
| private_ip_google_access | Lets VMs without an external address reach Google APIs. | bool | unset (off) |

### `firewall_rules` fields

| Field | Description | Type | Default |
|---|---|---|---|
| name | Name of the rule. | string | required |
| protocol | `tcp`, `udp`, `icmp`, `esp`, `ah`, `sctp`, `ipip` or `all`. | string | required |
| ports | Ports or ranges; ignored for protocols without ports. | list(string) | `[]` |
| source_ranges | Source address ranges. | list(string) | unset |
| source_tags | Source instances, by network tag. Give `source_ranges`, `source_tags` or both. | list(string) | unset |
| tags | The instances the rule applies to, by network tag; unset applies it to every instance. | list(string) | unset |
| action | `allow` or `deny`. | string | `allow` |
| priority | 0 (evaluated first) to 65535. | number | unset (1000) |

Rules are ingress rules.

### `nat_gateways` fields

| Field | Description | Type | Default |
|---|---|---|---|
| name | Name of the gateway. | string | required |
| region | Region of the gateway and its router. | string | required |
| router_name | Name of the Cloud Router created for it. | string | `<name>-router` |
| subnetworks | Names of subnets of this module to serve (all their ranges); unset serves every subnet of the region. | list(string) | unset |
| min_ports_per_vm | Ports reserved per VM. | number | unset (provider default) |
| log_errors | Log translation errors to Cloud Logging. | bool | `false` |

A gateway gives VMs without an external address outbound internet access, from addresses Google allocates.

---

## APIs and Service Account Prerequisites

To apply this module, the following are required:

### APIs
- Compute Engine API (`compute.googleapis.com`)

### Service Account Roles
The service account running Terraform must have at least:
- `roles/compute.networkAdmin` (for VPC, subnet, router, NAT and firewall management)
- `roles/compute.securityAdmin` (for firewall rules)
- `roles/compute.viewer` (for reading network resources)

## Development

What a machine needs to work on this module:

| Tool | Version | Used for |
|---|---|---|
| [Terraform](https://developer.hashicorp.com/terraform/install) | >= 1.11.4 | `fmt`, `validate`, `test` |
| [TFLint](https://github.com/terraform-linters/tflint) | >= 0.50 | lint (`.tflint.hcl`) |
| [terraform-docs](https://terraform-docs.io/user-guide/installation/) | >= 0.25 | the README's Inputs and Outputs tables (`.terraform-docs.yml`) |
| git | any | |

Nothing here needs Google Cloud credentials: `validate` and `tflint` read only the configuration, and the tests (`tests/`) run the module against mocked providers, creating nothing.

The checks CI runs (aka-org/gcp-infra's `terraform-module-ci.yml`, called from `.github/workflows/ci.yml`), from the repository root:

```sh
terraform fmt -check -recursive -diff
terraform init -backend=false && terraform validate && terraform test
tflint --init && tflint --recursive
terraform-docs --output-check .
```

After changing a variable or an output, run `terraform-docs .` to rewrite the README's tables.

CI validates and tests twice: on the lowest supported Google provider (6.8.0, read from `versions.tf`) and on the newest release the constraint allows. It runs on every pull request and once a week, so a new provider release that breaks the module shows up without a change here. To validate on the lowest locally, change the `google` constraint in every `versions.tf` to `6.8.0`, run `terraform init -backend=false -upgrade && terraform validate`, and revert.

An untracked `testing/` directory is ignored by git, for a caller configuration and its `terraform.tfvars` when trying the module against a real project. `terraform fmt -recursive` and `tflint --recursive` walk into it.

Releasing: add the version's section to `CHANGELOG.md`, merge, tag `vX.Y.Z` on `main`. The Terraform Registry publishes the tag.

---

## Changelog
See [CHANGELOG.md](CHANGELOG.md) for release history.

---

## License
Apache 2.0 - See [LICENSE](LICENSE)

### Releasing

A release is a merge to `main` whose `CHANGELOG.md` starts with a new `## X.Y.Z` heading: `.github/workflows/release.yml` runs the checks again, pushes the annotated tag `vX.Y.Z` (the Terraform Registry publishes from it) and creates the GitHub release with that changelog section as its notes (aka-org/gcp-infra's `changelog-release.yml`). A merge that adds no new version releases nothing; keep changes that aren't released yet under a `## Unreleased` heading above the newest version.
