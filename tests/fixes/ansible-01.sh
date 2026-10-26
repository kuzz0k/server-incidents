#!/usr/bin/env bash
# Эталонное решение ansible-01 (для tests/selftest.sh)
set -euo pipefail
cd /opt/trainer-ansible/status-site
sed -i 's/^       mode:/        mode:/' site.yml
sed -i 's|templates/status.conf.j2|templates/status.j2|' site.yml
sed -i 's/^statusport:/status_port:/' group_vars/web.yml
sed -i 's/notify: reload nginx/notify: Reload nginx/' site.yml
ANSIBLE_NOCOLOR=1 ansible-playbook -i inventory.ini site.yml >/dev/null
