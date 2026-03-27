  GNU nano 7.2                                             main.tf
provider "azurerm" {
  features {}

  resource_provider_registrations = "none"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-devops-integrador"
  location = "westus"
}

resource "azurerm_container_registry" "acr" {
  name                = "acrintegradorjese" # Debe ser único
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-integrador"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "devops-app"

  default_node_pool {
    name       = "default"
    node_count = 1 # Configuración mínima sugerida [cite: 31, 47]
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }
}