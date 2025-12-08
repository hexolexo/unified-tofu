terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.8.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

module "windows_vm" {
  source = "./modules/windows-libvirt-vm"

  vm_name_prefix    = "lab-windows-server"
  vm_count          = 0
  memory            = 8192
  vcpu              = 8
  windows_iso_path  = "/var/lib/libvirt/images/ISOs/WinSvr25.iso"
  virtio_iso_path   = "/var/lib/libvirt/images/ISOs/virtio-win-0.1.271.iso"
  autounattend_path = "${path.root}/vms/autounattend.xml"
}

module "alpine_vms" {
  source = "./modules/linux-libvirt-vm"

  vm_name_prefix = "lab-alpine-server"
  vm_count       = 0
  memory         = 512
  vcpu           = 2
  cloudinit_path = "${path.root}/vms/alpine_cloudinit.yml"
  linux_ISO_path = "/var/lib/libvirt/images/ISOs/Alpine-Cloudinit.qcow2"
}

module "debian_vms" {
  source = "./modules/linux-libvirt-vm"

  vm_name_prefix = "lab-debian-server"
  vm_count       = 1
  memory         = 8192
  vcpu           = 4
  cloudinit_path = "${path.root}/vms/debian_cloudinit.yml"
  linux_ISO_path = "/var/lib/libvirt/images/ISOs/debian-12-generic-amd64.qcow2"
}

