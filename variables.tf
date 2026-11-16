variable "project_id" {
  description = "The id of the host project"
  type        = string
}

variable "network_name" {
  description = "The name of the vpc network"
  type        = string
  default     = "main"
}

variable "firewall_rules" {
  description = "List of firewall rule resources to be created"
  type = list(object({
    name     = string
    protocol = string
    # Ignored for protocols without ports (icmp, esp, ah, sctp, ipip, all).
    ports = optional(list(string), [])
    # Where the traffic comes from: address ranges, or instances carrying
    # one of the source tags (at least one of the two).
    source_ranges = optional(list(string))
    source_tags   = optional(list(string))
    # The instances the rule applies to; unset applies it to every
    # instance in the network.
    tags = optional(list(string))
    # "allow" or "deny".
    action = optional(string, "allow")
    # 0 (first) to 65535; unset leaves the provider's default (1000).
    priority = optional(number)
  }))
  default = []

  validation {
    condition     = alltrue([for r in var.firewall_rules : contains(["allow", "deny"], r.action)])
    error_message = "A firewall rule's action must be \"allow\" or \"deny\"."
  }
}

variable "subnetworks" {
  description = "List of subnetwork resources to be created"
  type = list(object({
    name          = string
    region        = string
    ip_cidr_range = string
    # Named secondary ranges (GKE's pods and services ranges).
    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
    # Lets VMs without an external address reach Google APIs. Unset
    # leaves the provider's default (off).
    private_ip_google_access = optional(bool)
  }))
  default = []
}

variable "nat_gateways" {
  description = "List of Cloud NAT gateways to be created, each with its own Cloud Router"
  type = list(object({
    name   = string
    region = string
    # The Cloud Router the gateway hangs on; unset names it "<name>-router".
    router_name = optional(string)
    # The subnets served: unset serves every subnet of the region, with
    # all its ranges (secondary ones included, so GKE pods too); else the
    # names of subnets created by this module.
    subnetworks = optional(list(string))
    # Ports reserved per VM; unset leaves the provider's default.
    min_ports_per_vm = optional(number)
    # Logs translation errors to Cloud Logging.
    log_errors = optional(bool, false)
  }))
  default = []
}
