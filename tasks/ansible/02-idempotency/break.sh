#!/usr/bin/env bash
set -euo pipefail
TASK_ID=ansible-02
. "$(dirname "$0")/../../../lib/common.sh"

remove_user appuser
getent group appusers >/dev/null && groupdel appusers
rm -rf /opt/app /etc/app
sed -i '/^Managed by Ansible$/d' /etc/motd 2>/dev/null || true
mkdir -p /opt/trainer-ansible/base
cat > /opt/trainer-ansible/base/base.yml <<'EOF'
- name: Base setup
  hosts: localhost
  connection: local
  become: true
  tasks:
    - name: Create group
      ansible.builtin.shell: groupadd appusers

    - name: Create user
      ansible.builtin.shell: useradd -m -g appusers -s /bin/bash appuser

    - name: App directory
      ansible.builtin.shell: mkdir /opt/app && chown appuser:appusers /opt/app

    - name: MOTD
      ansible.builtin.shell: echo "Managed by Ansible" >> /etc/motd

    - name: App config
      ansible.builtin.shell: mkdir -p /etc/app && echo "log_level=info" >> /etc/app/app.conf
EOF
