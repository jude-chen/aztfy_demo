variable "project_prefix" {
  type    = string
  default = "aztfydemo"
}

variable "location" {
  type    = string
  default = "southcentralus"
}

variable "storage_account_tier" {
  type    = string
  default = "Standard"
}

variable "storage_replication_type" {
  type    = string
  default = "LRS"
}

variable "address_space" {
  type    = string
  default = "10.10.0.0/16"
}

variable "subnets" {
  type = map(string)
  default = {
    "app_subnet" = "10.10.0.0/24"
    "db_subnet"  = "10.10.1.0/24"
  }
}

variable "vm_subnet" {
  type        = string
  default     = "app_subnet"
  description = "The name of the subnet to build the VMs to."
}

variable "vm_admin_port" {
  type    = number
  default = 3389
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "image_publisher" {
  type    = string
  default = "MicrosoftWindowsServer"
}

variable "image_offer" {
  type    = string
  default = "WindowsServer"
}

variable "image_sku" {
  type    = string
  default = "2019-Datacenter"
}

variable "image_version" {
  type    = string
  default = "latest"
}
