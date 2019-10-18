data "azurerm_resource_group" "resource_group" {
  name = "${var.resource_group_name}"
}

data "azurerm_virtual_network" "resource_manager_vnet" {
  name = "${var.resource_manager_vnet}"
  resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
}

data "azurerm_subnet" "resource_manager_subnet" {
  name = "${var.resource_manager_subnet}"
  resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
  virtual_network_name = "${data.azurerm_virtual_network.resource_manager_vnet.name}"
}

data "azurerm_network_security_group" "resource_manager_nsg" {
  name = "${var.resource_manager_nsg}"
  resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
}