terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# Create Namespaces
resource "kubernetes_namespace" "namespaces" {
  for_each = toset(var.namespaces)

  metadata {
    name = each.key
    labels = {
      name        = each.key
      environment = var.environment
      cluster     = var.cluster_name
    }
  }
}

# Create ClusterRoles
resource "kubernetes_cluster_role" "admin" {
  metadata {
    name = "${var.cluster_name}-admin"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role" "developer" {
  metadata {
    name = "${var.cluster_name}-developer"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "configmaps", "secrets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "statefulsets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_cluster_role" "readonly" {
  metadata {
    name = "${var.cluster_name}-readonly"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }
}

# Create Service Accounts
resource "kubernetes_service_account" "accounts" {
  for_each = {
    for sa in var.service_accounts : "${sa.name}" => sa
  }

  metadata {
    name      = each.value.name
    namespace = kubernetes_namespace.namespaces[var.namespaces[0]].metadata[0].name
  }
}

# Create Role Bindings
resource "kubernetes_cluster_role_binding" "admin_bindings" {
  for_each = {
    for sa in var.service_accounts : sa.name => sa
    if sa.role == "admin"
  }

  metadata {
    name = "${var.cluster_name}-admin-binding-${each.key}"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.admin.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = each.key
    namespace = kubernetes_namespace.namespaces[var.namespaces[0]].metadata[0].name
  }
}

resource "kubernetes_role_binding" "developer_bindings" {
  for_each = {
    for sa in var.service_accounts : sa.name => sa
    if sa.role == "developer"
  }

  metadata {
    name      = "${var.cluster_name}-developer-binding-${each.key}"
    namespace = kubernetes_namespace.namespaces[var.namespaces[0]].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.developer.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = each.key
    namespace = kubernetes_namespace.namespaces[var.namespaces[0]].metadata[0].name
  }
}

resource "kubernetes_role_binding" "readonly_bindings" {
  for_each = {
    for sa in var.service_accounts : sa.name => sa
    if sa.role == "readonly"
  }

  metadata {
    name      = "${var.cluster_name}-readonly-binding-${each.key}"
    namespace = kubernetes_namespace.namespaces[var.namespaces[0]].metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.readonly.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = each.key
    namespace = kubernetes_namespace.namespaces[var.namespaces[0]].metadata[0].name
  }
}

# Add provider-specific RBAC (if needed)
resource "kubernetes_cluster_role_binding" "aws_auth" {
  count = var.provider_type == "aws" ? 1 : 0

  metadata {
    name = "${var.cluster_name}-aws-auth"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    kind      = "User"
    name      = "aws:${var.cluster_name}-auth"
    api_group = "rbac.authorization.k8s.io"
  }
}
