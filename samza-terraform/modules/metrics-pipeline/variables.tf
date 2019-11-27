variable "prefix" {
  description = "The prefix used for all resources in this example"
}

variable "metrics-prefix" {
  default     = "metrics"
  description = "The prefix used for all resources used by metrics"
}

variable "location" {
  description = "The Azure location where all resources in this example should be created"
}

variable "resource_group_name" {
  description = "The name of the resouce group"
}

variable "metrics_subnet" {
  description = "The name of the subnet the metrics node belongs to"
}

variable "metrics_vnet" {
  description = "The name of the vnet the metrics node belongs to"
}

variable "metrics_nsg" {
  description = "The name of the network security group the metrics instance belongs"
}

variable "username" {
  description = "The username used to login to the machine"
}

variable "password" {
  description = "The password used to login to the machine"
}

variable "kafka_ip" {
  description = "The IP address of a node in the Zookeeper cluster"
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
