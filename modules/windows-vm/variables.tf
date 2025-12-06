variable "vm_name_prefix" {
  type = string
}

variable "vm_count" {
  type    = number
  default = 1
}

variable "memory" {
  type    = number
  default = 8192
}

variable "vcpu" {
  type    = number
  default = 4
}

variable "disk_size" {
  type    = number
  default = 42949672960 # 40GB
}

variable "pool_path" {
  type    = string
  default = "/var/lib/libvirt/images/windows"
}

variable "windows_iso_path" {
  type = string
}

variable "virtio_iso_path" {
  type = string
}

variable "autounattend_path" {
  type = string
}

variable "network_mode" {
  type    = string
  default = "nat"
}

variable "network_addresses" {
  type    = list(string)
  default = ["192.168.100.0/24"]
}

variable "autostart" {
  type    = bool
  default = false
}
