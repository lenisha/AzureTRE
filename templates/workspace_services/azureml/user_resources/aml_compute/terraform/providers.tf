# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.5.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "=0.3.0"
    }
  }
  backend "azurerm" {
  }
}


provider "azurerm" {
  features {}
}
