variable "cluster_name" {
  type = string
}

variable "provider_type" {
  type = string
  description = "Cloud provider type (aws, azure, gcp)"
  validation {
    condition     = contains(["aws", "azure", "gcp"], var.provider_type)
    error_message = "Provider type must be one of: aws, azure, gcp"
  }
}


variable "region" {
  type = string
}

variable "node_count" {
  type = number
}

variable "node_size" {
  type = string
}

variable "environment" {
  type = string
}

variable "network_config" {
  type = object({
    vpc_cidr        = string
    subnet_cidrs    = list(string)
    allowed_cidrs   = list(string)
  })
}

variable "common_tags" {
  type = map(string)
}
