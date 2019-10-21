data "azurerm_resource_group" "resource_group" {
  name = "${var.resource_group_name}"
}

data "azurerm_virtual_network" "node_manager_vnet" {
  name = "${var.node_manager_vnet}"
  resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
}

data "azurerm_subnet" "node_manager_subnet" {
  name = "${var.node_manager_subnet}"
  resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
  virtual_network_name = "${data.azurerm_virtual_network.node_manager_vnet.name}"
}

data "azurerm_network_security_group" "node_manager_nsg" {
  name = "${var.node_manager_nsg}"
  resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
}