terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.19.1"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=2.20.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~>3.1.0"
    }
  }


}

