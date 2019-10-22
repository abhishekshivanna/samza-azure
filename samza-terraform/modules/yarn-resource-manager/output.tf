output "resource_manager_ip" {
  value = "${azurerm_network_interface.resource_manager_nic.private_ip_address}"
}