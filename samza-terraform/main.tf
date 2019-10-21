provider "azurerm" {
  version = "=1.34.0"
  skip_provider_registration = "${var.should_skip_provider_registration}"
  subscription_id = "${var.subscription_id}"
}

data "azurerm_resource_group" "resource_group" {
  name = "${var.resource_group_name}"
}

data "azurerm_network_security_group" "network_security_group" {
  name = "${var.network_security_group_name}"
  # location = "${data.azurerm_resource_group.resource_group.location}"
  resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location             = "${data.azurerm_resource_group.resource_group.location}"
  resource_group_name  = "${data.azurerm_resource_group.resource_group.name}"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${data.azurerm_resource_group.resource_group.name}"
  address_prefix       = "10.0.1.0/24"
}

module "yarn-resource-manager" {
  source = "./modules/yarn-resource-manager"
  resource_group_name =  "${data.azurerm_resource_group.resource_group.name}"
  password = "${var.password}"
  username = "${var.username}"

  resource_manager_subnet = "${azurerm_subnet.subnet.name}"
  resource_manager_vnet = "${azurerm_virtual_network.vnet.name}"
  resource_manager_nsg = "${data.azurerm_network_security_group.network_security_group.name}"
  prefix = "${var.prefix}"
  location = "${data.azurerm_resource_group.resource_group.location}"
}


module "yarn-node-manager" {
  source = "./modules/yarn-node-manager"
  resource_group_name =  "${data.azurerm_resource_group.resource_group.name}"
  password = "${var.password}"
  username = "${var.username}"

  node_manager_vnet = "${azurerm_virtual_network.vnet.name}"
  node_manager_subnet = "${azurerm_subnet.subnet.name}"
  node_manager_nsg = "${data.azurerm_network_security_group.network_security_group.name}"
  resource_manager_ip_address = "${module.yarn-resource-manager.resource_manager_ip}"

  prefix = "${var.prefix}"
  location = "${data.azurerm_resource_group.resource_group.location}"
}