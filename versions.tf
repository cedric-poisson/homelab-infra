terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
    backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sthomelabtfstate2972"
    container_name        = "tfstate"
    key                    = "homelab-infra.tfstate"
  }
}
 
provider "azurerm" {
  features {}
}
