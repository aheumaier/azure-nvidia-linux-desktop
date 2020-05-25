
data "azurerm_public_ip" "pip" {
  name                = azurerm_public_ip.pip.name
  resource_group_name = azurerm_virtual_machine.vm.resource_group_name
}

output "Login" {
  value     = random_string.str.result
}

output "public_ip_address" {
  value = "ssh azureuser@${data.azurerm_public_ip.pip.ip_address}"
}

