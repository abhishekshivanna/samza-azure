data "azurerm_resource_group" "resource_group" {
  name = "${var.resource_group_name}"
}

data "azurerm_virtual_network" "kafka_vnet" {
  name                = "${var.kafka_vnet}"
  resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
}

data "azurerm_subnet" "kafka_subnet" {
  name                  = "${var.kafka_subnet}"
  resource_group_name   = "${data.azurerm_resource_group.resource_group.name}"
  virtual_network_name  = "${data.azurerm_virtual_network.kafka_vnet.name}"
}

data "azurerm_network_security_group" "kafka_nsg" {
  name                = "${var.kafka_nsg}"
  resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
}

data "template_file" "kafka_config" {
  template = "${file("${path.module}/conf/server.properties")}"

  vars = {
    default_partition_count = "${var.default_partition_count}"
    zookeeper_ip = "${var.zookeeper_ip}"
  }
}