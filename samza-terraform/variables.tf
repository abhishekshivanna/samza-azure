variable "subscription_id" {
  description = "The Azure subscription ID"
}

variable "should_skip_provider_registration" {
  default = true
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
  default = 2
  description = "The number of Node Manager hosts to start"
}