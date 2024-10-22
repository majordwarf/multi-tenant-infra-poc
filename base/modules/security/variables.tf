variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "cluster_id" {
  description = "ID of the Kubernetes cluster"
  type        = string
}

variable "provider_type" {
  type = string
  description = "Cloud provider type (aws, azure, gcp)"
  validation {
    condition     = contains(["aws", "azure", "gcp"], var.provider_type)
    error_message = "Provider type must be one of: aws, azure, gcp"
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "network_config" {
  description = "Network configuration"
  type = object({
    vpc_cidr        = string
    subnet_cidrs    = list(string)
    allowed_cidrs   = list(string)
  })
}
