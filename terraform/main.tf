terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "openstack" {
  cloud = var.cloud_name
}

# 🔹 Groupe de sécurité
resource "openstack_networking_secgroup_v2" "ci_sg" {
  name        = "machine-ci-sg"
  description = "Sécurité pour machine CI/CD"
}

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

# 🔹 Générer le cloud-init
data "template_file" "cloudinit" {
  template = file("${path.module}/cloudinit.tpl")
  vars = {
    sysadmin_public_key      = file(var.sysadmin_key_path)
    devops_aya_public_key    = file(var.devops_aya_key_path)
    terraform_bot_public_key = file(var.terraform_bot_key_path)
    ansible_boot_public_key  = file(var.ansible_boot_key_path)
    admin_cidr               = var.admin_cidr
  }
}

# 🔹 Créer la machine CI
resource "openstack_compute_instance_v2" "machine_ci" {
  name            = "machine-CI"
  image_name      = var.image_name
  flavor_name     = var.flavor_name
  key_pair        = var.key_pair
  security_groups = [openstack_networking_secgroup_v2.ci_sg.name]
  network {
    name = var.network_name
  }

  user_data = data.template_file.cloudinit.rendered
}
