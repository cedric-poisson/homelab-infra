resource "azurerm_kubernetes_cluster" "homelab" {
  name                = "aks-homelab-dev"
  location            = azurerm_resource_group.homelab.location
  resource_group_name = azurerm_resource_group.homelab.name
  dns_prefix          = "akshomelabdev"
  oidc_issuer_enabled = true

  network_profile {
  network_plugin = "kubenet"
  service_cidr   = "10.100.0.0/16"
  dns_service_ip = "10.100.0.10"
}

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_B2s_v2"
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  identity {
    type = "SystemAssigned"
  }
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.homelab.kube_config_raw
  sensitive = true
}

