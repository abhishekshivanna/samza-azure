output "zookeeper_public_ip" {
  value = "${azurerm_public_ip.zookeeper_public_ip.ip_address}"
}

output "zookeeper_private_ip" {
  value = "${azurerm_network_interface.zookeeper_nic.private_ip_address}"
}