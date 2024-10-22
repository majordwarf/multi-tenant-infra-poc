variable "clusters" {
  description = "Map of clusters to be created"
  type = map(object({
    provider    = string
    region     = string
    node_count = number
    node_size  = string
    environment = string
    namespaces = list(string)
    service_accounts = list(object({
      name = string
      role = string
    }))
    network_config = object({
      vpc_cidr        = string
      subnet_cidrs    = list(string)
      allowed_cidrs   = list(string)
    })
  }))
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
