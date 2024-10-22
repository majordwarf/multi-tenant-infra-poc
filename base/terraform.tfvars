clusters = {
  "prod-us-east" = {
    provider    = "aws"
    region      = "us-east-1"
    node_count  = 3
    node_size   = "t3a.large"
    environment = "production"
    namespaces  = ["app", "monitoring", "system"]
    service_accounts = [
      {
        name = "admin-sa"
        role = "admin"
      },
      {
        name = "developer-sa"
        role = "developer"
      }
    ]
    network_config = {
      vpc_cidr      = "10.0.0.0/16"
      subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
      allowed_cidrs = ["10.0.0.0/8"]
    }
    service_accounts = [
      {
        name = "admin-sa"
        role = "admin"
      },
      {
        name = "developer-sa"
        role = "developer"
      },
      {
        name = "viewer-sa"
        role = "viewer"
      }
    ]
    security_config = {
      enable_pod_security_policies = true
      enable_network_policies     = true
      enable_vault               = true
      enable_cert_manager        = true
    }
  }
}

common_tags = {
  organization = "majordwarf"
  managed_by   = "terraform"
}
