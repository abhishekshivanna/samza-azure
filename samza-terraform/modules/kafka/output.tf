output "kafka_private_ip" {
  value = azurerm_network_interface.kafka_nic.private_ip_address
}
