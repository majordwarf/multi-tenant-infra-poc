output "cluster_id" {
  value = coalesce(
    try(aws_eks_cluster.cluster[0].id, ""),
    try(azurerm_kubernetes_cluster.cluster[0].id, ""),
    try(google_container_cluster.cluster[0].id, "")
  )
}

output "cluster_endpoint" {
  value = coalesce(
    try(aws_eks_cluster.cluster[0].endpoint, ""),
    try(azurerm_kubernetes_cluster.cluster[0].kube_config.0.host, ""),
    try(google_container_cluster.cluster[0].endpoint, "")
  )
}
