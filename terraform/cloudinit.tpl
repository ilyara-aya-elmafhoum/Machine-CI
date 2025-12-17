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

  - name: terraform-boot
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${terraform_boot_public_key}

  - name: ansible-boot
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${ansible_boot_public_key}

runcmd:
  - passwd -l root
  - if [ -f /root/.ssh/authorized_keys ]; then shred -u /root/.ssh/authorized_keys; fi

  - ufw --force reset
  - ufw default deny incoming
  - ufw default allow outgoing
  - ufw allow from ${admin_cidr} to any port 22 proto tcp
  - ufw allow 80/tcp
  - ufw allow 443/tcp
  - ufw allow 9000/tcp
  - ufw --force enable
