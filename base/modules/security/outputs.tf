output "cert_manager_status" {
  description = "Status of cert-manager installation"
  value       = helm_release.cert_manager.status
}

output "vault_status" {
  description = "Status of Vault installation"
  value       = helm_release.vault.status
}

output "security_group_ids" {
  description = "IDs of created security groups"
  value = {
    aws   = try(aws_security_group.cluster_sg[0].id, "")
    azure = try(azurerm_network_security_group.cluster_nsg[0].id, "")
    gcp   = try(google_compute_firewall.cluster_firewall[0].id, "")
  }
}
