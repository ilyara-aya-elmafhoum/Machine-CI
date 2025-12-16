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


variable "user_domain_name" {
  description = "Nom du domaine utilisateur OpenStack"
  type        = string
}

variable "region" {
  description = "Region OpenStack"
  type        = string
  
}

variable "ssh_key_name" {
  description = "Nom de la clé SSH dans OpenStack"
  type        = string
    
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

variable "terraform_boot_pub_key" {
  description = "Terraform bot SSH public key (content)"
  type        = string
}

variable "ansible_boot_pub_key" {
  description = "Ansible Boot SSH public key (content)"
  type        = string
}

variable "network_name" {
  description = "Nom du réseau sur lequel créer la VM"
  type        = string
  default     = "10.0.0.11"
  
}
variable "machine_ci_private_ip" {
  description = "Adresse IP privée fixe pour la machine CI"
  type        = string
}
variable "network_id" {
  description = "ID du réseau privé utilisé par la machine CI"
  type        = string
  
}

variable "subnet_id" {
  description = "ID du sous-réseau privé utilisé par la machine CI"
  type        = string
  
}

