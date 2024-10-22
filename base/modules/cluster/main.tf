# AWS EKS
resource "aws_eks_cluster" "cluster" {
  count = var.provider_type == "aws" ? 1 : 0
  
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster[0].arn
  vpc_config {
    subnet_ids = aws_subnet.cluster[*].id
  }
  tags = var.common_tags
}

# Azure AKS
resource "azurerm_kubernetes_cluster" "cluster" {
  count = var.provider_type == "azure" ? 1 : 0

  name                = var.cluster_name
  location            = var.region
  resource_group_name = azurerm_resource_group.cluster[0].name
  dns_prefix         = var.cluster_name

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_size
  }

  tags = var.common_tags
}

# GCP GKE
resource "google_container_cluster" "cluster" {
  count = var.provider_type == "gcp" ? 1 : 0

  name     = var.cluster_name
  location = var.region

  node_pool {
    name       = "default"
    node_count = var.node_count

    node_config {
      machine_type = var.node_size
    }
  }
}
