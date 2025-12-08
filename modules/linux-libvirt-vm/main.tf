terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.8.0"
    }
  }
}

resource "libvirt_pool" "vm" {
  name = "${var.vm_name_prefix}_pool"
  type = "dir"
  path = var.pool_path != "" ? var.pool_path : "/var/lib/libvirt/images/pools/${var.vm_name_prefix}"
}

resource "libvirt_volume" "base" {
  name   = "${var.vm_name_prefix}_base.qcow2"
  pool   = libvirt_pool.vm.name
  source = var.linux_ISO_path
  format = "qcow2"
}

resource "libvirt_volume" "disk" {
  count          = var.vm_count
  name           = "${var.vm_name_prefix}_${count.index}.qcow2"
  pool           = libvirt_pool.vm.name
  base_volume_id = libvirt_volume.base.id
  size           = var.disk_size * 1086373952 // GB to bytes
  format         = "qcow2"
}

resource "libvirt_cloudinit_disk" "init" {
  count = var.vm_count
  name  = "${var.vm_name_prefix}_cloudinit_${count.index}.iso"
  pool  = libvirt_pool.vm.name
  user_data = templatefile("${var.cloudinit_path}", {
    hostname = "${var.vm_name_prefix}-${count.index}"
    ssh_key  = file("~/.ssh/id_rsa.pub")
  })
}

resource "libvirt_domain" "vm" {
  count     = var.vm_count
  name      = "${var.vm_name_prefix}-${count.index}"
  memory    = var.memory
  vcpu      = var.vcpu
  autostart = var.autostart

  disk {
    volume_id = libvirt_volume.disk[count.index].id
  }

  cloudinit = libvirt_cloudinit_disk.init[count.index].id

  network_interface {
    network_name   = "default"
    wait_for_lease = false
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}
