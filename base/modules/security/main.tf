locals {
  is_aws   = var.provider_type == "aws"
  is_azure = var.provider_type == "azure"
  is_gcp   = var.provider_type == "gcp"
}
resource "kubernetes_network_policy" "default_deny_all" {
  metadata {
    name = "default-deny-all"
    annotations = {
      "cluster.name" = var.cluster_name
      "environment"  = var.environment
    }
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

resource "kubernetes_network_policy" "allow_dns" {
  metadata {
    name = "allow-dns"
    annotations = {
      "cluster.name" = var.cluster_name
      "environment"  = var.environment
    }
  }

  spec {
    pod_selector {}
    egress {
      ports {
        port     = 53
        protocol = "UDP"
      }
      ports {
        port     = 53
        protocol = "TCP"
      }
    }
    policy_types = ["Egress"]
  }
}

# Pod Security Standards
resource "kubernetes_cluster_role" "restricted_psp" {
  metadata {
    name = "${var.cluster_name}-restricted-psp"
  }

  rule {
    api_groups     = ["policy"]
    resources      = ["podsecuritypolicies"]
    verbs          = ["use"]
    resource_names = [kubernetes_pod_security_policy.restricted.metadata[0].name]
  }
}

resource "kubernetes_pod_security_policy" "restricted" {
  metadata {
    name = "${var.cluster_name}-restricted"
    annotations = {
      "seccomp.security.alpha.kubernetes.io/allowedProfileNames" = "runtime/default"
      "apparmor.security.beta.kubernetes.io/allowedProfileNames" = "runtime/default"
    }
  }

  spec {
    privileged                 = false
    allow_privilege_escalation = false
    
    volumes = [
      "configMap",
      "emptyDir",
      "projected",
      "secret",
      "downwardAPI",
      "persistentVolumeClaim",
    ]

    run_as_user {
      rule = "MustRunAsNonRoot"
    }

    se_linux {
      rule = "RunAsAny"
    }

    supplemental_groups {
      rule = "MustRunAs"
      range {
        min = 1
        max = 65535
      }
    }

    fs_group {
      rule = "MustRunAs"
      range {
        min = 1
        max = 65535
      }
    }

    read_only_root_filesystem = true
  }
}

# Cloud-specific security configurations
resource "aws_security_group" "cluster_sg" {
  count  = local.is_aws ? 1 : 0
  name   = "${var.cluster_name}-cluster-sg"
  vpc_id = var.network_config.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.network_config.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "azurerm_network_security_group" "cluster_nsg" {
  count               = local.is_azure ? 1 : 0
  name                = "${var.cluster_name}-cluster-nsg"
  location            = var.region
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-api-server"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.network_config.allowed_cidrs
    destination_address_prefix = "*"
  }
}

resource "google_compute_firewall" "cluster_firewall" {
  count   = local.is_gcp ? 1 : 0
  name    = "${var.cluster_name}-cluster-firewall"
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = var.network_config.allowed_cidrs
  target_tags   = ["${var.cluster_name}-nodes"]
}

# Security tooling installation
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "vault" {
  name             = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  namespace        = "vault"
  create_namespace = true

  set {
    name  = "server.dev.enabled"
    value = var.environment != "production"
  }
}
