module "clusters" {
  for_each = var.clusters
  source   = "./modules/cluster"

  cluster_name = each.key
  provider_type = each.value.provider
  region       = each.value.region
  node_count   = each.value.node_count
  node_size    = each.value.node_size
  environment  = each.value.environment
  network_config = each.value.network_config
  common_tags  = var.common_tags

  providers = {
    aws     = aws[each.value.provider == "aws" ? each.value.region : null]
    azurerm = azurerm[each.value.provider == "azure" ? each.value.region : null]
    google  = google[each.value.provider == "gcp" ? each.value.region : null]
  }
}

module "security" {
  for_each = var.clusters
  source   = "./modules/security"

  cluster_name    = each.key
  cluster_id      = module.clusters[each.key].cluster_id
  provider_type   = each.value.provider
  environment     = each.value.environment
  network_config  = each.value.network_config
  depends_on      = [module.clusters]
}

module "rbac" {
  for_each = var.clusters
  source   = "./modules/rbac"

  cluster_name     = each.key
  provider_type    = each.value.provider
  namespaces      = each.value.namespaces
  service_accounts = each.value.service_accounts
  environment     = each.value.environment
  depends_on      = [module.clusters]
}
