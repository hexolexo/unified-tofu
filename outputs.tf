output "windows_vms" {
  value = {
    names = module.windows_test.vm_names
    ids   = module.windows_test.vm_ids
  }
}
