data "azurerm_kubernetes_service_versions" "aks_stable_version" {
  location        = azurerm_resource_group.aks_rg.location
  include_preview = false

}

resource "azurerm_log_analytics_workspace" "insights" {
  name                = "logs-${random_pet.aksrandom.id}"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  retention_in_days   = "30"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${azurerm_resource_group.aks_rg.name}-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "${azurerm_resource_group.aks_rg.name}-cluster"
  kubernetes_version  = data.azurerm_kubernetes_service_versions.aks_stable_version.latest_version
  node_resource_group = "${azurerm_resource_group.aks_rg.name}-nrg"

  default_node_pool {
    name                 = "systempool"
    vm_size              = "Standard_DS2_v2"
    orchestrator_version = data.azurerm_kubernetes_service_versions.aks_stable_version.latest_version
    enable_auto_scaling  = true
    max_count            = 2
    min_count            = 1
    os_disk_size_gb      = 30
    type                 = "VirtualMachineScaleSets"
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = "dev"
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }

    tags = {
      "nodepool-type" = "system"
      "environment"   = "dev"
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  azure_policy_enabled = true
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.insights.id
  }

  role_based_access_control_enabled = true
  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = [azuread_group.aks_administrators.id]
  }

  windows_profile {
    admin_username = var.windows_admin_username
    admin_password = var.windows_admin_password
  }

  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  network_profile {
    network_plugin = "azure"
  }


  tags = {
    "Environment" = "dev"
  }
}

# resource "azurerm_kubernetes_cluster_node_pool" "name" {
#   name                  = "linux101"
#   kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
#   enable_auto_scaling   = true
#   max_count             = 2
#   min_count             = 1
#   mode                  = "User"
#   orchestrator_version  = data.azurerm_kubernetes_service_versions.aks_stable_version.latest_version
#   os_disk_size_gb       = 30
#   os_type               = "Linux"
#   vm_size               = "Standard_DS2_v2"
#   priority              = "Regular"

#   node_labels = {
#     "nodepool-type" = "user"
#     "environment"   = "production"
#     "nodepoolos"    = "linux"
#     "app"           = "java-apps"
#   }

# }
