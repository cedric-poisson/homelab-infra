resource "azurerm_virtual_network" "homelab" {
  name                = "vnet-homelab-dev"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.homelab.location
  resource_group_name = azurerm_resource_group.homelab.name
}

resource "azurerm_subnet" "vms" {
  name                 = "snet-vms"
  resource_group_name  = azurerm_resource_group.homelab.name
  virtual_network_name = azurerm_virtual_network.homelab.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.homelab.name
  virtual_network_name = azurerm_virtual_network.homelab.name
  address_prefixes     = ["10.0.2.0/24"]
}