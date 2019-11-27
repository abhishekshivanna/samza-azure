output "node_manager_ips" {
  value = [azurerm_public_ip.node_manager_public_ip.*.ip_address]
}
