locals {
  rg_name    = "${var.project_prefix}-rg"
  sa_name    = "${var.project_prefix}sa01"
  avset_name = "${var.project_prefix}avset"
  lbpip_name = "${var.project_prefix}-ip"
  vnet_name  = "${var.project_prefix}-vnet"
  lb_name    = "${var.project_prefix}-lb"
  vm_name    = "${var.project_prefix}-vm"
  kv_name    = "${var.project_prefix}-kv"
}
