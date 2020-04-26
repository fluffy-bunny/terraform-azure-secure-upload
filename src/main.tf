terraform {
  backend "azurerm" {
    # Due to a limitation in backend objects, variables cannot be passed in.
    # Do not declare an access_key here. Instead, export the
    # ARM_ACCESS_KEY environment variable.

    storage_account_name  = "stterraformsecureupload"
    container_name        = "tstate"
    key                   = "terraform.tfstate"
  }
}
# Configure the Azure provider
provider "azurerm" {
  version = "=2.0.0"
  features {
   
  }
}
 
resource "azurerm_resource_group" "rg" {
  name     = var.az_resource_group_name
  location = var.az_resource_group_location
  tags     = var.tags
}

data "azurerm_subscription" "primary" {}
data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}

resource "azurerm_storage_account" "main" {
  name                     = var.az_storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags     = var.tags
}
resource "azurerm_storage_container" "main" {
  name                  = var.az_storage_container_name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}  