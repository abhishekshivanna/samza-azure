output "zookeeper_private_ip" {
  value = azurerm_network_interface.zookeeper_nic.private_ip_address
}
