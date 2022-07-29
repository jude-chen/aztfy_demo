resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "${var.vm_name}-ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.rg_name
  availability_set_id   = var.avset_id
  vm_size               = var.vm_size
  network_interface_ids = [azurerm_network_interface.nic.id]

  storage_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  storage_os_disk {
    name          = "${var.vm_name}-osdisk"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = var.vm_name
    admin_username = "azureadmin"
    admin_password = random_password.admin_password.result
  }

  os_profile_windows_config {}
}
