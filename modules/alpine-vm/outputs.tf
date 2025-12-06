output "vms" {
  value       = libvirt_domain.alpine_vm
  description = "Windows VM domain resources"
}

output "vm_names" {
  value = [for alpine_vm in libvirt_domain.alpine_vm : alpine_vm.name]
}

output "vm_ids" {
  value = [for alpine_vm in libvirt_domain.alpine_vm : alpine_vm.id]
}
