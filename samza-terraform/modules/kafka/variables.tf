variable "prefix" {
  description = "The prefix used for all resources in this example"
}

variable "kafka-prefix" {
  default     = "kafka"
  description = "The prefix used for all resources used by Kafka"
}

variable "location" {
  description = "The Azure location where all resources in this example should be created"
}

variable "resource_group_name" {
  description = "The name of the resouce group"
}

variable "kafka_subnet" {
  description = "The name of the subnet the Kafka node belongs to"
}

variable "kafka_vnet" {
  description = "The name of the vnet the Kafka node belongs to"
}

variable "kafka_nsg" {
  description = "The name of the network security group the Kafka instance belongs"
}

variable "username" {
  description = "The username used to login to the machine"
}

variable "password" {
  description = "The password used to login to the machine"
}

variable "default_partition_count" {
  description = "The default number of partitions topics in the cluster are created with"
}

variable "zookeeper_ip" {
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
