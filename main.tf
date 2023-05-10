# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "pt-rg" {
  name     = "pt-resources"
  location = "South India"
  tags = {
    env = "dev"
  }
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "pt-vn" {
  name                = "pt-network"
  resource_group_name = azurerm_resource_group.pt-rg.name
  location            = azurerm_resource_group.pt-rg.location
  address_space       = ["10.0.0.0/16"]
  tags = {
    env = "dev"
  }
}