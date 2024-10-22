variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
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

variable "namespaces" {
  description = "List of namespaces to create"
  type        = list(string)
}

variable "service_accounts" {
  description = "List of service accounts to create"
  type = list(object({
    name = string
    role = string
  }))
}
