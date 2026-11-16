variable "project_id" {
  description = "The id of the host project"
  type        = string
  default     = ""
}

variable "network_self_link" {
  description = "Self link of the VPC network"
  type        = string
  default     = ""
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

  validation {
    condition     = alltrue([for r in var.firewall_rules : contains(["allow", "deny"], r.action)])
    error_message = "A firewall rule's action must be \"allow\" or \"deny\"."
  }
}
