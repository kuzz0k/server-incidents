#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-52
. "$(dirname "$0")/../../../lib/common.sh"

systemctl is-active -q ssh || systemctl is-active -q ssh.socket || systemctl start ssh
remove_user reporter
useradd --create-home --shell /bin/bash reporter
install -d -m 0700 /root/trainer-keys
rm -f /root/trainer-keys/reporter_ed25519 /root/trainer-keys/reporter_ed25519.pub
ssh-keygen -q -t ed25519 -N '' -C reporter@laptop -f /root/trainer-keys/reporter_ed25519
install -d -m 0700 -o reporter -g reporter /home/reporter/.ssh
echo "from=\"10.20.0.0/16\" $(cat /root/trainer-keys/reporter_ed25519.pub)" > /home/reporter/.ssh/authorized_keys
chown reporter:reporter /home/reporter/.ssh/authorized_keys
chmod 0600 /home/reporter/.ssh/authorized_keys
cut -d' ' -f2 /root/trainer-keys/reporter_ed25519.pub > "$TASK_VAR/key"
chage -E 2024-01-01 reporter
