terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "<fill-from-repo-1-output>"
    storage_account_name = "<fill-from-repo-1-output>"
    container_name       = "tfstate"
    key                  = "static-website-${var.environment}.tfstate"
  }
}

provider "azurerm" {
  features {}
}
