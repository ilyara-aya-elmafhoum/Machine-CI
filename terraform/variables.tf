variable "cloud_name" {
  description = "Nom du cloud ou provider utilisé (ex: OpenStack, AWS, etc.)"
  type        = string
}

variable "image_name" {
  description = "Nom de l'image à utiliser pour la machine"
  type        = string
}

variable "flavor_name" {
  description = "Type de machine ou flavor à utiliser (CPU, RAM, Disk)"
  type        = string
}

variable "key_pair" {
  description = "Nom de la paire de clés SSH pour la VM"
  type        = string
}

variable "network_name" {
  description = "Nom du réseau auquel la machine sera attachée"
  type        = string
}

variable "admin_cidr" {
  description = "CIDR autorisé pour l'accès administrateur (ex: 192.168.1.0/24)"
  type        = string
}

variable "sysadmin_key_path" {
  description = "Chemin vers la clé SSH du sysadmin"
  type        = string
}

variable "devops_aya_key_path" {
  description = "Chemin vers la clé SSH d'Ayana DevOps"
  type        = string
}

variable "terraform_bot_key_path" {
  description = "Chemin vers la clé SSH utilisée par Terraform Bot"
  type        = string
}

variable "ansible_boot_key_path" {
  description = "Chemin vers la clé publique SSH utilisée par Ansible"
  type        = string
}
