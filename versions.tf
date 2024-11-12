terraform {
  required_version = ">=1.3.8"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
      configuration_aliases = [ azurerm.sub-oai1]
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.13.1"
    }
  }
}

provider "azurerm" {
  alias = "sub-oai1"
  features {}
  subscription_id = local.sub-oai1
}