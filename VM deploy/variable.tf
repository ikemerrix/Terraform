variable "location" {
  default     = "Eastus"
  description = "The location where resources are created"
}
variable "vm_size" {
  default = "Standard_DS1_v2"
}
variable "hostname" {
  default = "myterraformvm"
}
variable "image_uri" {
  default = ""
}
variable "os_type" {
  default = "windows"
}
variable "admin_username" {
  default = "admin"
}
variable key_vault_name {
  description = "Name of the keyVault"
  default     = ""
}
variable encryption_key_url {
  description = "URL to encrypt Key"
  default     = ""
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

