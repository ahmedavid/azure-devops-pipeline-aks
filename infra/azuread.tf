resource "azuread_group" "aks_administrators" {
  display_name     = "${azurerm_resource_group.aks_rg.name}-cluster-administrators"
  security_enabled = true
  mail_enabled     = false
}
