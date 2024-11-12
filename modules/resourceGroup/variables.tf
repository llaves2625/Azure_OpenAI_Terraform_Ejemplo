variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where the resource group should be created"
  type        = string
}


variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}