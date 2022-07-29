output "network_interface_id" {
  value = azurerm_network_interface.nic.id
}

output "vm_admin_password" {
  value = random_password.admin_password.result
}
