output "windows_vms" {
  value = {
    names = module.windows_vm.vm_names
    ids   = module.windows_vm.vm_ids
  }
}

output "alpine_vms" {
  value = {
    names = module.alpine_vms.vm_names
    ids   = module.alpine_vms.vm_ids
  }
}
