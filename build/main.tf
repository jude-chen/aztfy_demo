resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
}

resource "azurerm_storage_account" "stor" {
  name                     = local.sa_name
  location                 = var.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
}

resource "azurerm_availability_set" "avset" {
  name                         = local.avset_name
  location                     = var.location
  resource_group_name          = azurerm_resource_group.rg.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_public_ip" "lbpip" {
  name                = local.lbpip_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  location            = var.location
  address_space       = ["${var.address_space}"]
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  for_each             = var.subnets
  name                 = each.key
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["${each.value}"]
}

resource "azurerm_lb" "lb" {
  resource_group_name = azurerm_resource_group.rg.name
  name                = local.lb_name
  location            = var.location

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.lbpip.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "BackendPool1"
}

resource "azurerm_lb_nat_rule" "tcp" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "RDP-VM-${count.index}"
  protocol                       = "Tcp"
  frontend_port                  = "5000${count.index + 1}"
  backend_port                   = var.vm_admin_port
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  count                          = 2
}

resource "azurerm_lb_rule" "lb_rule" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "HttpRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.lb_probe.id
  depends_on                     = [azurerm_lb_probe.lb_probe]
}

resource "azurerm_lb_probe" "lb_probe" {
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "HttpProbe"
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_network_interface_nat_rule_association" "natrule" {
  network_interface_id  = element(module.vm.*.network_interface_id, count.index)
  ip_configuration_name = "${local.vm_name}${count.index + 1}-ipconfig"
  nat_rule_id           = element(azurerm_lb_nat_rule.tcp.*.id, count.index)
  count                 = 2
}

module "vm" {
  source          = "./modules/virtual_machine_avset"
  count           = 2
  vm_name         = "${local.vm_name}${count.index + 1}"
  location        = var.location
  rg_name         = azurerm_resource_group.rg.name
  avset_id        = azurerm_availability_set.avset.id
  vm_size         = var.vm_size
  subnet_id       = azurerm_subnet.subnet[var.vm_subnet].id
  image_publisher = var.image_publisher
  image_offer     = var.image_offer
  image_sku       = var.image_sku
  image_version   = var.image_version
}


//Key vault to store the admin passwords for the VMs
module "admin_kv" {
  source   = "./modules/admin_key_vault"
  kv_name  = local.kv_name
  location = var.location
  rg_name  = azurerm_resource_group.rg.name
  admin_passwords = {
    for i in range(2) :
    "${local.vm_name}${i + 1}-password" => element(module.vm.*.vm_admin_password, i)
  }
}

moved {
  from = azurerm_key_vault.kv
  to   = module.admin_kv.azurerm_key_vault.kv
}
