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
}
