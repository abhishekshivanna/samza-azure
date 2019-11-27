variable "prefix" {
  description = "The prefix used for all resources in this example"
}

variable "rm-prefix" {
  default     = "resource-manager"
  description = "The prefix used for all resources used by the Resource Manager"
}

variable "location" {
  description = "The Azure location where all resources in this example should be created"
}

variable "resource_group_name" {
  description = "The name of the resouce group"
}

variable "resource_manager_subnet" {
  description = "The name of the subnet the Resource Manager belongs to"
}

variable "resource_manager_vnet" {
  description = "The name of the vnet the Resource Manager belongs to"
}

variable "resource_manager_nsg" {
  description = "The name of the network security group the Resource Manager belongs"
}

variable "username" {
  description = "The username used to login to the machine"
}

variable "password" {
  description = "The password used to login to the machine"
}

variable "vm_size" {
  description = "The VM SKU"
}

variable "storage_image_publisher" {
  description = "Image publisher"
}

variable "storage_image_offer" {
  description = "Image offer"
}

variable "storage_image_sku" {
  description = "Image SKU"
}

variable "storage_image_version" {
  description = "Image Version"
}
