resource "azurerm_virtual_machine" "bastionvm" {
    
    name = "${var.bastionvm}"
    location = "${var.location}"
    resource_group_name = "${var.rgname}"
    network_interface_ids = ["${var.bastion_network_interface_ids}"]
    vm_size = "${var.bastionvmsize}"
    delete_os_disk_on_termination = "${var.delete_os_disk_on_termination}"
    delete_data_disks_on_termination = "${var.delete_data_disk_on_termination}"
    storage_image_reference {
        publisher = "MicrosoftWindowsDesktop"
        offer = "Windows-10"
        sku = "rs5-pro"
        version = "latest"
    }
    storage_os_disk {
        name = "${var.bastionvm}-osdisk"
        caching = "ReadWrite"
        create_option = "FromImage"
    }
    storage_data_disk{
        name = "${var.bastionvm}-datadisk"
        caching = "None"
        create_option = "Empty"
        managed_disk_type = "StandardSSD_LRS"
        disk_size_gb = 64
        lun = 0
    }
    os_profile {
        computer_name = "${var.bastionvm}"
        admin_username = "${var.bastionadminuser}"
        admin_password = "${var.bastionadminpwd}"
    }
    os_profile_windows_config {

    }
    boot_diagnostics {
        enabled     = "${var.boot_diagnostics}"
        storage_uri = "${var.boot_diagnostics == "true" ? join(",", azurerm_storage_account.bastiondiag.*.primary_blob_endpoint) : "" }"
        }
}
resource "azurerm_storage_account" "bastiondiag" {
    name = "diag${lower(var.bastionvm)}"
    resource_group_name = "${var.rgname}"
    location = "${var.location}"
    account_tier = "${element(split("_", var.boot_diagnostics_sa_type),0)}"
    account_replication_type = "${element(split("_", var.boot_diagnostics_sa_type),1)}"
    tags = {
        environemnt = "Demo"
    }
}