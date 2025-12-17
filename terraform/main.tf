terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54.0"
    }
  }
  required_version = ">= 1.6.0"
}

provider "openstack" {
  user_name        = var.OS_USERNAME
  password         = var.OS_PASSWORD
  auth_url         = var.OS_AUTH_URL
  tenant_id        = var.OS_PROJECT_ID
  user_domain_name = var.user_domain_name
  region           = var.region
}

# Security group CI
resource "openstack_networking_secgroup_v2" "ci_sg" {
  name        = "machine-ci-sg"
  description = "Sécurité pour la machine CI"
}

# Rule SSH
resource "openstack_networking_secgroup_rule_v2" "allow_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.admin_cidr
  security_group_id = openstack_networking_secgroup_v2.ci_sg.id
}

# Rule HTTP
resource "openstack_networking_secgroup_rule_v2" "allow_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  security_group_id = openstack_networking_secgroup_v2.ci_sg.id
}

# Rule HTTPS
resource "openstack_networking_secgroup_rule_v2" "allow_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  security_group_id = openstack_networking_secgroup_v2.ci_sg.id
}

# Rule SonarQube
resource "openstack_networking_secgroup_rule_v2" "allow_sonarqube" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9000
  port_range_max    = 9000
  security_group_id = openstack_networking_secgroup_v2.ci_sg.id
}

# Cloud-init
data "template_file" "cloudinit" {
  template = file("${path.module}/cloudinit.tpl")
  vars = {
    sysadmin_public_key       = var.sysadmin_pub_key
    devops_aya_public_key     = var.devops_aya_pub_key
    terraform_boot_public_key = var.terraform_boot_pub_key
    ansible_boot_public_key   = var.ansible_boot_pub_key
    admin_cidr                = var.admin_cidr
  }
}

# Port privé pour CI
resource "openstack_networking_port_v2" "ci_port" {
  name       = "ci-port"
  network_id = var.network_id

  security_group_ids = [
    openstack_networking_secgroup_v2.ci_sg.id
  ]

  fixed_ip {
    subnet_id  = var.subnet_id
    ip_address = var.machine_ci_private_ip
  }
}

# Instance CI
resource "openstack_compute_instance_v2" "machine_ci" {
  name        = "machine-CI"
  image_name  = var.vm_image
  flavor_name = var.vm_flavor
  key_pair    = var.ssh_key_name

  network {
    port = openstack_networking_port_v2.ci_port.id
  }

  security_groups = [
    openstack_networking_secgroup_v2.ci_sg.name
  ]

  user_data = data.template_file.cloudinit.rendered
}

# Floating IP
resource "openstack_networking_floatingip_v2" "ci_fip" {
  pool    = var.floating_ip_pool
  port_id = openstack_networking_port_v2.ci_port.id
}

# Output
output "ci_ip" {
  description = "Adresse IP publique de la machine CI"
  value       = openstack_networking_floatingip_v2.ci_fip.address
}
