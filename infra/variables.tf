variable "resource_group_name" {
  type    = string
  default = "aks-rg"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "environment" {
  type    = string
  default = "qa"
}

variable "ssh_public_key" {
  default = "ssh-keys/terraform-azure.pub"
  type    = string
}

variable "windows_admin_username" {
  default = "azureuser"
  type    = string
}

variable "windows_admin_password" {
  default = "P@ssw0rd123456"
  type    = string
}

