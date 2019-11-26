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
  vm_size = var.vm_size

  storage_image_publisher = var.storage_image_publisher
  storage_image_offer = var.storage_image_offer
  storage_image_sku = var.storage_image_sku
  storage_image_version = var.storage_image_version
}

module "yarn-node-manager" {
  source = "./modules/yarn-node-manager"

  nm_count = "${var.nm_count}"
  resource_group_name =  "${data.azurerm_resource_group.resource_group.name}"
  password = "${var.password}"
  username = "${var.username}"

  node_manager_vnet = "${azurerm_virtual_network.vnet.name}"
  node_manager_subnet = "${azurerm_subnet.subnet.name}"
  node_manager_nsg = "${data.azurerm_network_security_group.network_security_group.name}"
  resource_manager_ip_address = "${module.yarn-resource-manager.resource_manager_ip}"

  prefix = "${var.prefix}"
  location = "${data.azurerm_resource_group.resource_group.location}"
  vm_size = var.samza_vm_size

  storage_image_publisher = var.storage_image_publisher
  storage_image_offer = var.storage_image_offer
  storage_image_sku = var.storage_image_sku
  storage_image_version = var.storage_image_version
}

module "zookeeper" {
  source = "./modules/zookeeper"
  password = "${var.password}"
  username = "${var.username}"
  prefix = "${var.prefix}"
  resource_group_name =  "${data.azurerm_resource_group.resource_group.name}"
  zookeeper_vnet = "${azurerm_virtual_network.vnet.name}"
  zookeeper_subnet = "${azurerm_subnet.subnet.name}"
  zookeeper_nsg = "${data.azurerm_network_security_group.network_security_group.name}"
  location = "${data.azurerm_resource_group.resource_group.location}"
  vm_size = var.vm_size

  storage_image_publisher = var.storage_image_publisher
  storage_image_offer = var.storage_image_offer
  storage_image_sku = var.storage_image_sku
  storage_image_version = var.storage_image_version
}

module "kafka" {
  source = "./modules/kafka"
  default_partition_count = "1"
  kafka_vnet = "${azurerm_virtual_network.vnet.name}"
  kafka_subnet = "${azurerm_subnet.subnet.name}"
  kafka_nsg = "${data.azurerm_network_security_group.network_security_group.name}"
  location = "${data.azurerm_resource_group.resource_group.location}"
  password = "${var.password}"
  username = "${var.username}"
  prefix = "${var.prefix}"
  resource_group_name =  "${data.azurerm_resource_group.resource_group.name}"
  zookeeper_ip = "${module.zookeeper.zookeeper_private_ip}"
  vm_size = var.vm_size

  storage_image_publisher = var.storage_image_publisher
  storage_image_offer = var.storage_image_offer
  storage_image_sku = var.storage_image_sku
  storage_image_version = var.storage_image_version
}

module "metrics-pipeline" {
  source = "./modules/metrics-pipeline"
  metrics_vnet = "${azurerm_virtual_network.vnet.name}"
  metrics_subnet = "${azurerm_subnet.subnet.name}"
  metrics_nsg = "${data.azurerm_network_security_group.network_security_group.name}"
  location = "${data.azurerm_resource_group.resource_group.location}"
  password = "${var.password}"
  username = "${var.username}"
  prefix = "${var.prefix}"
  resource_group_name =  "${data.azurerm_resource_group.resource_group.name}"
  kafka_ip = "${module.kafka.kafka_private_ip}"
  vm_size = var.vm_size

  storage_image_publisher = var.storage_image_publisher
  storage_image_offer = var.storage_image_offer
  storage_image_sku = var.storage_image_sku
  storage_image_version = var.storage_image_version
}