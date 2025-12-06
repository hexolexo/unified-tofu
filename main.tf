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

module "windows_test" {
  source = "./modules/windows-vm"

  vm_name_prefix    = "lab-windows-server"
  vm_count          = 2
  memory            = 8192
  vcpu              = 4
  windows_iso_path  = "/var/lib/libvirt/images/ISOs/WinSvr25.iso"
  virtio_iso_path   = "/var/lib/libvirt/images/ISOs/virtio-win-0.1.271.iso"
  autounattend_path = "${path.root}/vms/autounattend.xml"
}

