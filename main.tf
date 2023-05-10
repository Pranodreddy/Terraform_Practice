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

resource "azurerm_subnet" "pt-subnet" {
  name                 = "pt-subnet"
  resource_group_name  = azurerm_resource_group.pt-rg.name
  virtual_network_name = azurerm_virtual_network.pt-vn.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "pt-nw-sg" {
  name                = "pt-nw-sg"
  location            = azurerm_resource_group.pt-rg.location
  resource_group_name = azurerm_resource_group.pt-rg.name

  security_rule {
    name                       = "pt-dev-rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "pt-sga" {
  subnet_id                 = azurerm_subnet.pt-subnet.id
  network_security_group_id = azurerm_network_security_group.pt-nw-sg.id
}

resource "azurerm_public_ip" "pt-pubIp" {
  name                = "pt-pubIp"
  resource_group_name = azurerm_resource_group.pt-rg.name
  location            = azurerm_resource_group.pt-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "pt-nwInterface" {
  name                = "pt-nwInterface"
  location            = azurerm_resource_group.pt-rg.location
  resource_group_name = azurerm_resource_group.pt-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.pt-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pt-pubIp.id
  }
}