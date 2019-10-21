data "azurerm_resource_group" "resource_group" {
  name = "${var.resource_group_name}"
}

data "azurerm_virtual_network" "zookeeper_vnet" {
  name                = "${var.zookeeper_vnet}"
  resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
}

data "azurerm_subnet" "zookeeper_subnet" {
  name                  = "${var.zookeeper_subnet}"
  resource_group_name   = "${data.azurerm_resource_group.resource_group.name}"
  virtual_network_name  = "${data.azurerm_virtual_network.zookeeper_vnet.name}"
}

data "azurerm_network_security_group" "zookeeper_nsg" {
  name                = "${var.zookeeper_nsg}"
  resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
}