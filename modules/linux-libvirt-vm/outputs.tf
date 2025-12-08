output "vms" {
  value       = libvirt_domain.vm
  description = "alpine VM domain resources"
}

output "vm_names" {
  value = [for vm in libvirt_domain.vm : vm.name]
}

output "vm_ids" {
  value = [for vm in libvirt_domain.vm : vm.id]
}
