variable "kv_name" {
  type = string
}

variable "location" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "admin_passwords" {
  type = map(string)
}
