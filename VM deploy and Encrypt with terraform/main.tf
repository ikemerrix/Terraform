#arm provider 
provider "azurerm" {
  version = "~>2.0"
  features {}

#enter service principal and subscription details 
  subscription_id = ""
  client_id       = ""
  client_secret   = ""
  tenant_id       = ""
  
}
resource "random_id" "num_net" {
  byte_length = 8
}

data "azurerm_resource_group" "myrg" {
  name     = "myrg" #existing resourcegroup name here 
}
#add vnet name 
resource "azurerm_virtual_network" "myvnet"{
  name    = "myvnetname"
  location   = "${data.azurerm_resource_group.myrg.location}"
  resource_group_name = "${data.azurerm_resource_group.myrg.name}"
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "mysubnet" {
  name  = "default"
  address_prefix  = "10.0.1.0/24"
  virtual_network_name = azurerm_virtual_network.myvnet.name
  resource_group_name = "${data.azurerm_resource_group.myrg.name}"
}
#existing Keyvault
data "azurerm_key_vault" "mykeyvault" { 
  name = "myvaultname"                      
  resource_group_name = "morrisonRG"
}

#keyvault secret name 
data "azurerm_key_vault_secret" "mysecret" {
  name = "vmkey"
  key_vault_id = data.azurerm_key_vault.mykeyvault.id
}

resource "azurerm_network_interface" "nic"{
  name = "vmnic"
  location = "${data.azurerm_resource_group.myrg.location}"
  resource_group_name = "${data.azurerm_resource_group.myrg.name}"
    ip_configuration {
      name                          = "myNicConfiguration"
      subnet_id                     = "${azurerm_subnet.mysubnet.id}"
      private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.hostname}"
  location              = "${data.azurerm_resource_group.myrg.location}"
  resource_group_name   = "${data.azurerm_resource_group.myrg.name}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]

  os_profile_windows_config {
    provision_vm_agent = true
  }
  storage_image_reference {
    id = var.image_uri
  }
  storage_os_disk {
    name          = "${var.hostname}-osdisk1"
    os_type       = "${var.os_type}"
    caching       = "ReadWrite"
    create_option = "FromImage" 
  }

  os_profile {
    computer_name  = "${var.hostname}"
    admin_username = "${var.admin_username}"
    admin_password = "${data.azurerm_key_vault_secret.mysecret.value}"
  }
}

resource "azurerm_virtual_machine_extension" "disk-encryption" {
  name                 = "DiskEncryption"
  virtual_machine_id   = azurerm_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Security"
  type                 = "AzureDiskEncryption"
  type_handler_version = "2.2"
  depends_on           = [azurerm_virtual_machine.vm]

  settings = <<SETTINGS
{
  "EncryptionOperation": "EnableEncryption",
  "KeyVaultURL": "${data.azurerm_key_vault.mykeyvault.vault_uri}",
  "KeyVaultResourceId": "${data.azurerm_key_vault.mykeyvault.id}",
  "KeyEncryptionKeyURL": "${var.encryption_key_url}",
  "KekVaultResourceId": "${data.azurerm_key_vault.mykeyvault.id}",
  "KeyEncryptionAlgorithm": "RSA-OAEP",
  "VolumeType": "All"
}
SETTINGS
}

resource "azurerm_managed_disk" "mydisk" {
  name                 = "${var.hostname}-disk1"
  location             = "${var.location}"
  resource_group_name  = "${data.azurerm_resource_group.myrg.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}

resource "azurerm_virtual_machine_data_disk_attachment" "add-disk" {
  managed_disk_id    = azurerm_managed_disk.mydisk.id
  virtual_machine_id = azurerm_virtual_machine.vm.id
  lun                = "10"
  caching            = "ReadWrite"
}