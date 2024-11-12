variable "prefix" {
  type        = string
  description = "Naming prefix for resources"
  default     = "w2m"
}

resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "resource_group" {
  provider = azurerm

  name     = "${var.resource_group_name}-${random_integer.suffix.result}"
  location = var.location
  tags     = var.tags

}

