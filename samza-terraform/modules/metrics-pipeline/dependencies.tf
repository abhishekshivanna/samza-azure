data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "metrics_vnet" {
  name                = var.metrics_vnet
  resource_group_name = data.azurerm_resource_group.resource_group.name
}

data "azurerm_subnet" "metrics_subnet" {
  name                 = var.metrics_subnet
  resource_group_name  = data.azurerm_resource_group.resource_group.name
  virtual_network_name = data.azurerm_virtual_network.metrics_vnet.name
}

data "azurerm_network_security_group" "metrics_nsg" {
  name                = var.metrics_nsg
  resource_group_name = data.azurerm_resource_group.resource_group.name
}

data "template_file" "kafka_server_config" {
  template = file("${path.module}/conf/kafka-server.conf")

  vars = {
    kafka_ip = var.kafka_ip
  }
}
