output "namespaces" {
  description = "Created namespaces"
  value       = [for ns in kubernetes_namespace.namespaces : ns.metadata[0].name]
}

output "service_accounts" {
  description = "Created service accounts"
  value = {
    for sa in kubernetes_service_account.accounts :
    sa.metadata[0].name => {
      name      = sa.metadata[0].name
      namespace = sa.metadata[0].namespace
    }
  }
}

output "roles" {
  description = "Created roles"
  value = {
    admin     = kubernetes_cluster_role.admin.metadata[0].name
    developer = kubernetes_cluster_role.developer.metadata[0].name
    readonly  = kubernetes_cluster_role.readonly.metadata[0].name
  }
}
