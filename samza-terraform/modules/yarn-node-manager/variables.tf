variable "prefix" {
  description = "The prefix used for all resources in this example"
}

variable "rm-prefix" {
  default = "resource-manager"
  description = "The prefix used for all resources used by the Resource Manager"
}

variable "location" {
  default = "westus2"
  description = "The Azure location where all resources in this example should be created"
}

variable "resource_group_name" {
  description = "The name of the resouce group"
}

variable "node_manager_subnet" {
  description = "The name of the subnet the Resource Manager belongs to"
}

variable "node_manager_vnet" {
  description = "The name of the vnet the Resource Manager belongs to"
}

variable "node_manager_nsg" {
  description = "The name of the network security group the Resource Manager belongs"
}

variable "username" {
  description = "The username used to login to the machine"
}

variable "password" {
  description = "The password used to login to the machine"
}

variable "resource_manager_ip_address" {
  description = "The IP address of the resource manager that this node manager instance will connect to"
}

locals {
  yarn_config_path = "${path.root}/conf/yarn-site.xml"
}

