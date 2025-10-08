# variables.tf
variable "openstack_cloud" {
  description = "Nom du cloud OpenStack"
  type        = string
}

variable "OS_USERNAME" {
  description = "Nom d'utilisateur OpenStack"
  type        = string
}

variable "OS_PASSWORD" {
  description = "Mot de passe OpenStack"
  type        = string
  sensitive   = true
}

variable "OS_PROJECT_ID" {
  type        = string
  description = "UUID du projet OpenStack"
}

variable "OS_PROJECT_NAME" {
  description = "Nom du projet OpenStack"
  type        = string
}

variable "OS_AUTH_URL" {
  description = "URL d'authentification OpenStack"
  type        = string
}

variable "ssh_key_name" {
  description = "Nom de la clé SSH dans OpenStack"
  type        = string
  default     = "my-ssh-key"  
}



variable "vm_flavor" {
  description = "Type d'instance VM"
  type        = string
  
}

variable "vm_image" {
  description = "Image de la VM"
  type        = string
 
}

variable "floating_ip_pool" {
  description = "Pool d'IP flottantes"
  type        = string
  
}

variable "admin_cidr" {
  description = "CIDR admin pour les règles de sécurité"
  type        = string
  
}

variable "sysadmin_pub_key" {
  description = "Sysadmin SSH public key (content)"
  type        = string
}

variable "devops_aya_pub_key" {
  description = "DevOps Aya SSH public key (content)"
  type        = string
}

variable "terraform_bot_pub_key" {
  description = "Terraform bot SSH public key (content)"
  type        = string
}
variable "network_name" {
  description = "Nom du réseau sur lequel créer la VM"
  type        = string

}
