output "windows_server_libvirt" {
  value = {
    names = module.windows_server_libvirt.vm_names
    ids   = module.windows_server_libvirt.vm_ids
  }
}

output "alpine_server_libvirt" {
  value = {
    names = module.alpine_server_libvirt.vm_names
    ids   = module.alpine_server_libvirt.vm_ids
  }
}

output "debian_server_libvirt" {
  value = {
    names = module.debian_server_libvirt.vm_names
    ids   = module.debian_server_libvirt.vm_ids
  }
}

output "debian_desktop_libvirt" {
  value = {
    names = module.debian_desktop_libvirt.vm_names
    ids   = module.debian_desktop_libvirt.vm_ids
  }
}

