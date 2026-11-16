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

variable "subnetwork_self_links" {
  description = "Self link of each subnetwork created by the module, by name"
  type        = map(string)
  default     = {}
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
}
