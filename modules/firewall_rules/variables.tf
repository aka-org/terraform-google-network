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
    name          = string
    protocol      = string
    ports         = list(string)
    source_ranges = list(string)
    tags          = list(string)
  }))
}