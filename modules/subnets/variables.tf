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
  description = "List of subnetwork resources to  be created"
  type = list(object({
    name          = string
    region        = string
    ip_cidr_range = string
  }))
}