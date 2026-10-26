#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-08
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit webhook
rm -f /etc/sudoers.d/deploy.conf /etc/sudoers.d/deploy /etc/sudoers.d/zz-deploy /etc/sudoers.d/ops-admins
getent group ops >/dev/null || groupadd ops
if ! id -u deploy >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash deploy
fi
usermod -aG ops deploy
echo "deploy:$(head -c 18 /dev/urandom | base64)" | chpasswd

tmp=$(mktemp)
echo '%ops ALL=(ALL:ALL) ALL' > "$tmp"
visudo -cqf "$tmp"
install -m 0440 "$tmp" /etc/sudoers.d/ops-admins
echo 'deploy ALL=(root) NOPASSWD: /usr/bin/systemctl restart webhook, /usr/bin/systemctl status webhook' > "$tmp"
visudo -cqf "$tmp"
install -m 0440 "$tmp" /etc/sudoers.d/deploy.conf
rm -f "$tmp"

write_unit webhook <<EOF
[Unit]
Description=Webhook receiver

[Service]
Environment=NAME=webhook PORT=8008
ExecStart=/usr/bin/python3 $WEBAPP
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now webhook >/dev/null 2>&1
