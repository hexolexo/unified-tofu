output "vms" {
  value = libvirt_domain.vm
  description = "Windows VM domain resources"
}

output "vm_names" {
  value = [for vm in libvirt_domain.vm : vm.name]
}

output "vm_ids" {
  value = [for vm in libvirt_domain.vm : vm.id]
}

output "network_id" {
  value = libvirt_network.vm_network.id
}
