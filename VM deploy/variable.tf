variable "location" {
  default     = "Eastus"
  description = "The location where resources are created"
}
variable "vm_size" {
  default = "Standard_DS1_v2"
}
variable "hostname" {
  default = "myterrafvm"
}
variable "image_uri" {
  default = "/subscriptions/f2aeaccd-73bf-45ef-8603-946e33fa5570/resourceGroups/terraformRG/providers/Microsoft.Compute/galleries/ismorrisSIG/images/terrimage/versions/0.0.1"
}
variable "os_type" {
  default = "windows"
}
variable "admin_username" {
  default = "merrix"
}
variable key_vault_name {
  description = "Name of the keyVault"
  default     = "testkeyVault123"
}
variable encryption_key_url {
  description = "URL to encrypt Key"
  default     = "https://freshvault.vault.azure.net/keys/encryptionkey/4702cbcb8bb044109e987696c9f8c5f9"
}
variable encryption_algorithm {
  description = " Algo for encryption"
  default     = "RSA-OAEP"
}
variable "volume_type" {
  default = "All"
}
variable "encrypt_operation" {
  default = "EnableEncryption"
}

