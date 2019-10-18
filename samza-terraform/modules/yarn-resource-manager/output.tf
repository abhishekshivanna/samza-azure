output "resource_manager_ip" {
  value = "${azurerm_public_ip.resource_manager_public_ip.ip_address}"
}