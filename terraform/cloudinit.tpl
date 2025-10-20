#cloud-config
ssh_pwauth: false
disable_root: true

# Utilisateurs
users:
  - name: sysadmin
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${sysadmin_pub_key}

  - name: devops-aya
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${devops_aya_pub_key}

  - name: terraform-boot
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${terraform_boot_pub_key}

  - name: ansible-boot
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${ansible_boot_pub_key}

# Packages à installer
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
  - fail2ban
  - needrestart
  - ansible

# Configuration Fail2Ban pour SSH
write_files:
  - path: /etc/fail2ban/jail.local
    permissions: '0644'
    content: |
      [sshd]
      enabled = true
      port    = ssh
      filter  = sshd
      logpath = /var/log/auth.log
      maxretry = 3
      bantime = 600
      findtime = 600

# Commandes à exécuter au démarrage
runcmd:
  # Sécurisation SSH
  - passwd -l root
  - if [ -f /root/.ssh/authorized_keys ]; then shred -u /root/.ssh/authorized_keys; fi

  # Configuration pare-feu
  - ufw --force reset
  - ufw default deny incoming
  - ufw default allow outgoing
  - ufw allow from ${admin_cidr} to any port 22 proto tcp comment "SSH Admin Access"
  - ufw allow 80/tcp comment "HTTP"
  - ufw allow 443/tcp comment "HTTPS"
  - ufw allow 9000/tcp comment "SonarQube"
  - ufw --force enable

  # Mises à jour automatiques
  - dpkg-reconfigure -f noninteractive unattended-upgrades
  - systemctl enable unattended-upgrades
  - systemctl restart unattended-upgrades

  # Installation et vérification d’Ansible
  - apt-add-repository --yes --update ppa:ansible/ansible
  - apt update
  - apt install -y ansible
  - ansible --version

  # Nettoyage et durcissement
  - apt autoremove -y
  - apt clean
  - systemctl enable fail2ban
  - systemctl restart fail2ban
  - needrestart -r a
