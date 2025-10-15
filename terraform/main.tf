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
  user_domain_name = "Default"
  region           = "dc3-a"
}

#  Groupe de sécurité
resource "openstack_networking_secgroup_v2" "ci_sg" {
  name        = "machine-ci-sg"
  description = "Sécurité pour machine CI/CD"
}

# Règles d’accès
resource "openstack_networking_secgroup_rule_v2" "allow_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  security_group_id = openstack_networking_secgroup_v2.ci_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "allow_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  security_group_id = openstack_networking_secgroup_v2.ci_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "allow_sonarqube" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9000
  port_range_max    = 9000
  security_group_id = openstack_networking_secgroup_v2.ci_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "allow_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.admin_cidr
  security_group_id = openstack_networking_secgroup_v2.ci_sg.id
}

#  Générer le cloud-init à partir du template
data "template_file" "cloudinit" {
  template = file("${path.module}/cloudinit.tpl")
  vars = {
    sysadmin_public_key      = var.sysadmin_pub_key
    devops_aya_public_key    = var.devops_aya_pub_key
    terraform_boot_public_key = var.terraform_boot_pub_key
    ansible_boot_public_key  = var.ansible_boot_pub_key
    admin_cidr               = var.admin_cidr
  }
}

#  Création de la machine CI
resource "openstack_compute_instance_v2" "machine_ci" {
  name            = "machine-CI"
  image_name      = var.vm_image
  flavor_name     = var.vm_flavor
  key_pair        = var.ssh_key_name
  security_groups = [openstack_networking_secgroup_v2.ci_sg.name]

  network {
    name     = var.network_name       # ex: private-net
    fixed_ip = var.machine_ci_private_ip  # IP privée fixe
  }

  user_data = data.template_file.cloudinit.rendered
}

#  Adresse IP flottante publique
resource "openstack_networking_floatingip_v2" "ci_floating_ip" {
  pool = var.floating_ip_pool
}

resource "openstack_compute_floatingip_associate_v2" "ci_fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.ci_floating_ip.address
  instance_id = openstack_compute_instance_v2.machine_ci.id
}
