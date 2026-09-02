terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "Azureregistry"
    storage_account_name = "pracbacksta"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}

}