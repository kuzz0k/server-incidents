#!/usr/bin/env bash
set -euo pipefail
TASK_ID=ansible-01
. "$(dirname "$0")/../../../lib/common.sh"

P=/opt/trainer-ansible/status-site
rm -rf "$P" /srv/www/status
rm -f /etc/nginx/sites-enabled/status.conf
nginx_apply || true
mkdir -p "$P/group_vars" "$P/templates"
cat > "$P/inventory.ini" <<'EOF'
[web]
localhost ansible_connection=local
EOF
cat > "$P/group_vars/web.yml" <<'EOF'
statusport: 8888
status_message: "status: ok"
EOF
cat > "$P/templates/status.j2" <<'EOF'
# Managed by Ansible
server {
    listen {{ status_port }};
    server_name _;
    root /srv/www/status;
    index index.html;
}
EOF
cat > "$P/site.yml" <<'EOF'
- name: Status site
  hosts: web
  become: true
  tasks:
    - name: Install nginx
      ansible.builtin.apt:
        name: nginx
        state: present

    - name: Status page directory
      ansible.builtin.file:
        path: /srv/www/status
        state: directory
       mode: "0755"

    - name: Status page
      ansible.builtin.copy:
        content: "{{ status_message }} {{ ansible_hostname }}\n"
        dest: /srv/www/status/index.html
        mode: "0644"

    - name: Site config
      ansible.builtin.template:
        src: templates/status.conf.j2
        dest: /etc/nginx/sites-enabled/status.conf
        mode: "0644"
      notify: reload nginx

    - name: nginx is running
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: true

  handlers:
    - name: Reload nginx
      ansible.builtin.service:
        name: nginx
        state: reloaded
EOF
