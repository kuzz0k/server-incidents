#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-38
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit legacy-billing billing-proxy.socket billing-proxy.service
for t in PREROUTING OUTPUT; do
  while iptables -t nat -S "$t" 2>/dev/null | grep -q -- '--dport 8038'; do
    rule=$(iptables -t nat -S "$t" | grep -- '--dport 8038' | head -1 | sed 's/^-A /-D /')
    eval "iptables -t nat $rule"
  done
done

write_unit legacy-billing <<EOF
[Unit]
Description=Legacy billing (port is hardcoded)
After=network.target

[Service]
Environment=NAME=legacy-billing PORT=20280 "BODY=legacy billing"
ExecStart=/usr/bin/python3 $WEBAPP
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now legacy-billing >/dev/null 2>&1
wait_for_port 20280
systemctl cat legacy-billing | sha256sum > "$TASK_VAR/unit.sha256"
