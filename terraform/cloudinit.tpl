#cloud-config
ssh_pwauth: false
disable_root: true

users:
  - name: sysadmin
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${sysadmin_public_key}

  - name: devops-aya
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${devops_aya_public_key}

  - name: terraform-bot
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${terraform_bot_public_key}

  - name: ansible-boot
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${ansible_boot_public_key}

package_update: true
package_upgrade: true
packages:
  - unzip
  - git
  - curl
  - wget
  - software-properties-common
  - gnupg2
  - lsb-release
  - python3-pip
  - ufw
  - unattended-upgrades
  - ansible

runcmd:
  - passwd -l root
  - ufw --force reset
  - ufw default deny incoming
  - ufw default allow outgoing
  - ufw allow from ${admin_cidr} to any port 22 proto tcp
  - ufw allow 80/tcp
  - ufw allow 443/tcp
  - ufw allow 9000/tcp
  - ufw --force enable
  - dpkg-reconfigure -f noninteractive unattended-upgrades
  - sleep 60
  # Installer Ansible via PPA 
  - sudo apt-add-repository --yes --update ppa:ansible/ansible
  - sudo apt update
  - sudo apt install -y ansible
  - ansible --version
