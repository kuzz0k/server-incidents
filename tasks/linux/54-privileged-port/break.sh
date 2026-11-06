#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-54
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit ldap-proxy
remove_user ldapproxy
useradd --system --no-create-home --shell /usr/sbin/nologin ldapproxy
remember unpriv-port "$(sysctl -n net.ipv4.ip_unprivileged_port_start)"
port_listening 389 && die "Порт 389 уже занят на этом сервере — задача не сможет проверить решение"

write_unit ldap-proxy <<EOF
[Unit]
Description=LDAP proxy
After=network.target

[Service]
User=ldapproxy
Environment=NAME=ldap-proxy PORT=389 "BODY=ldap-proxy ok"
ExecStart=/usr/bin/python3 $WEBAPP
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now ldap-proxy >/dev/null 2>&1 || true
