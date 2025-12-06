terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.8.0"
    }
  }
}

# Pool per VM group keeps things organized
resource "libvirt_pool" "vm_pool" {
  name = "${var.vm_name_prefix}_pool"
  type = "dir"
  target {
    path = var.pool_path
  }
}

# Create floppy image with autounattend.xml
resource "null_resource" "autounattend_floppy" {
  count = var.vm_count

  provisioner "local-exec" {
    # HACK: Using dd + mkfs.fat because libvirt provider doesn't support floppies directly
    command = <<-EOT
      sudo dd if=/dev/zero of=/tmp/autounattend-${var.vm_name_prefix}-${count.index}.img bs=1024 count=1440 2>/dev/null
      sudo mkfs.fat /tmp/autounattend-${var.vm_name_prefix}-${count.index}.img >/dev/null 2>&1
      sudo mkdir -p /tmp/floppy_mount_${count.index}
      sudo mount /tmp/autounattend-${var.vm_name_prefix}-${count.index}.img /tmp/floppy_mount_${count.index}
      sudo cp ${var.autounattend_path} /tmp/floppy_mount_${count.index}/autounattend.xml
      sudo umount /tmp/floppy_mount_${count.index}
      sudo rm -rf /tmp/floppy_mount_${count.index}
    EOT
  }

  # Recreate if autounattend changes
  triggers = {
    autounattend_hash = filemd5(var.autounattend_path)
  }
}

resource "libvirt_volume" "floppy" {
  count  = var.vm_count
  name   = "autounattend-${var.vm_name_prefix}-${count.index}.img"
  pool   = libvirt_pool.vm_pool.name
  source = "/tmp/autounattend-${var.vm_name_prefix}-${count.index}.img"
  format = "raw"

  depends_on = [null_resource.autounattend_floppy]
}

resource "libvirt_volume" "windows_iso" {
  name   = "${var.vm_name_prefix}-windows.iso"
  pool   = libvirt_pool.vm_pool.name
  source = var.windows_iso_path
  format = "raw"
}

resource "libvirt_volume" "virtio_iso" {
  name   = "${var.vm_name_prefix}-virtio.iso"
  pool   = libvirt_pool.vm_pool.name
  source = var.virtio_iso_path
  format = "raw"
}

resource "libvirt_volume" "disk" {
  count  = var.vm_count
  name   = "${var.vm_name_prefix}-${count.index}-disk.qcow2"
  pool   = libvirt_pool.vm_pool.name
  size   = var.disk_size
  format = "qcow2"
}

resource "libvirt_network" "vm_network" {
  name      = "${var.vm_name_prefix}_network"
  mode      = var.network_mode
  addresses = var.network_addresses
  autostart = true

  dhcp {
    enabled = true
  }
}

resource "libvirt_domain" "vm" {
  count  = var.vm_count
  name   = "${var.vm_name_prefix}-${count.index}"
  memory = var.memory
  vcpu   = var.vcpu

  cpu {
    mode = "host-passthrough"
  }

  machine = "q35"

  # WARN: This XSLT is fragile - test after libvirt provider updates
  xml {
    xslt = <<-EOF
      <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
        <xsl:output omit-xml-declaration="yes" indent="yes" />
        <xsl:template match="node()|@*">
          <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
          </xsl:copy>
        </xsl:template>
        <xsl:template match="/domain/features">
          <features>
            <xsl:apply-templates select="node()|@*"/>
            <hyperv>
              <relaxed state="on"/>
              <vapic state="on"/>
              <spinlocks state="on" retries="8191"/>
            </hyperv>
          </features>
        </xsl:template>
        <xsl:template match="/domain/devices">
          <devices>
            <xsl:apply-templates select="node()|@*"/>
            <disk type='file' device='floppy'>
              <driver name='qemu' type='raw'/>
              <source file='${libvirt_volume.floppy[count.index].id}'/>
              <target dev='fda' bus='fdc'/>
            </disk>
          </devices>
        </xsl:template>
        <xsl:template match="//disk[@device='disk']/target">
          <target dev='sda' bus='sata'/>
        </xsl:template>
        <xsl:template match="//disk[@device='cdrom'][1]/target">
          <target dev='sdb' bus='sata'/>
        </xsl:template>
        <xsl:template match="//disk[@device='cdrom'][2]/target">
          <target dev='sdc' bus='sata'/>
        </xsl:template>
        <xsl:template match="//interface[@type='network']/model">
          <model type='e1000'/>
        </xsl:template>
      </xsl:stylesheet>
    EOF
  }

  network_interface {
    network_id     = libvirt_network.vm_network.id
    wait_for_lease = false
  }

  disk {
    volume_id = libvirt_volume.disk[count.index].id
  }

  disk {
    file = libvirt_volume.windows_iso.id
  }

  disk {
    file = libvirt_volume.virtio_iso.id
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  boot_device {
    dev = ["cdrom", "hd"]
  }

  autostart = var.autostart
}
