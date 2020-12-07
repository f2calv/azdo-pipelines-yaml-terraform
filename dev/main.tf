terraform {
  required_version = "=0.14.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.39.0"
    }
  }

  #https://www.terraform.io/docs/backends/types/azurerm.html
  backend "azurerm" {
    storage_account_name = "__backendAzureRmStorageAccountName__"
    container_name       = "__backendAzureRmContainerName__"
    key                  = "__backendAzureRmKey__"
    access_key           = "__backendAzureRmStorageAccountKey__"
  }
}

provider "azurerm" {
  #maybe not needed, but left in because of some weird azdo extension warnings...
  features {}
}

locals {
  cluster_name = null #todo: replace null with your desired cluster name here!
  location     = "West Europe"
  env          = "dev"
}

//https://www.terraform.io/docs/providers/azurerm/d/resource_group.html
resource "azurerm_resource_group" "rg" {
  name     = "${local.cluster_name}-rg"
  location = local.location

  tags = {
    environment = local.env
  }
}

//https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${local.cluster_name}-dns"

  # used to group all the internal objects of this cluster
  node_resource_group = "${local.cluster_name}-rg-node"

  # azure will assign the id automatically, i.e. Managed identity
  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  role_based_access_control {
    enabled = true
  }

  addon_profile {
    kube_dashboard {
      enabled = false
    }
  }

  tags = {
    environment = local.env
  }
}

//https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/container_registry
resource "azurerm_container_registry" "acr" {
  name                = "${local.cluster_name}acr"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"
  admin_enabled       = true

  tags = {
    environment = local.env
  }
}

//https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "AcrPull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}
