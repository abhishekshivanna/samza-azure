variable "subscription_id" {
  description = "The Azure subscription ID"
}

variable "should_skip_provider_registration" {
  default     = true
  description = "Should the AzureRM Provider skip registering the Resource Providers it supports. Setting this to true will skip registration with Azure Resouces we may not have access to as part of the subscription"
}

variable "prefix" {
  description = "The prefix used for all resources in this example"
}

variable "location" {
  description = "The Azure location where all resources in this example should be created"
}

variable "resource_group_name" {
  description = "The name of the resouce group"
}

variable "username" {
  description = "The username used to login to the machine"
}

variable "password" {
  description = "The password used to login to the machine"
}

variable "network_security_group_name" {
  description = "The predefined network security group to use for the cluster"
}

variable "nm_count" {
  default     = 2
  description = "The number of Node Manager hosts to start"
}

# Define VM class/size for all VMs

variable "samza_vm_size" {
  default     = "Standard_D16s_v3"
  description = "The VM SKU for Samza Infra"
}

variable "vm_size" {
  default     = "Standard_D8_v3"
  description = "The VM SKU"
}

# To find available images, run command below in azure shell
# az vm image list --offer CentOS --all --output table

variable "storage_image_publisher" {
  default     = "OpenLogic"
  description = "Image publisher"
}

variable "storage_image_offer" {
  default     = "CentOS"
  description = "Image offer"
}

variable "storage_image_sku" {
  default     = "7.7"
  description = "Image SKU"
}

variable "storage_image_version" {
  default     = "latest"
  description = "Image Version"
}

variable "yarn_nodemanager_resource_memory_mb" {
  default = "8192"
  description = "Amount of physical memory, in MB, that can be allocated for containers"
}
