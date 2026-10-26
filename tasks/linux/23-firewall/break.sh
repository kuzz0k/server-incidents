#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-23
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit dashboard fw-hardening
iptables -D INPUT -j HARDENING 2>/dev/null || true
iptables -F HARDENING 2>/dev/null || true
iptables -X HARDENING 2>/dev/null || true

cat > /usr/local/sbin/fw-hardening.sh <<'EOF'
#!/bin/bash
# Security hardening rules (SEC-417)
set -e
iptables -N HARDENING 2>/dev/null || iptables -F HARDENING
iptables -C INPUT -j HARDENING 2>/dev/null || iptables -I INPUT 1 -j HARDENING
# закрыть отладочный порт
iptables -A HARDENING -p tcp --dport 8099 -j REJECT
# закрыть неиспользуемые порты приложений
iptables -A HARDENING -p tcp --dport 8023 -j DROP
EOF
chmod 0755 /usr/local/sbin/fw-hardening.sh

write_unit fw-hardening <<'EOF'
[Unit]
Description=Firewall hardening rules
After=network-pre.target
Before=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/sbin/fw-hardening.sh
ExecStop=-/bin/sh -c 'iptables -D INPUT -j HARDENING; iptables -F HARDENING; iptables -X HARDENING'

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now fw-hardening >/dev/null 2>&1

write_unit dashboard <<EOF
[Unit]
Description=Ops dashboard
After=network.target

[Service]
DynamicUser=yes
Environment=NAME=dashboard PORT=8023
ExecStart=/usr/bin/python3 $WEBAPP
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now dashboard >/dev/null 2>&1
wait_for_port 8023
