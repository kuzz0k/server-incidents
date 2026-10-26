#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-09
. "$(dirname "$0")/../../../lib/common.sh"

systemctl is-active -q ssh || systemctl is-active -q ssh.socket || systemctl start ssh

remove_user alice
useradd --create-home --shell /usr/sbin/nologin alice

install -d -m 0700 /root/trainer-keys
rm -f /root/trainer-keys/alice_ed25519 /root/trainer-keys/alice_ed25519.pub
ssh-keygen -q -t ed25519 -N '' -C alice@laptop -f /root/trainer-keys/alice_ed25519

mkdir -p /home/alice/.ssh
cp /root/trainer-keys/alice_ed25519.pub /home/alice/.ssh/authorized_keys
chmod 0777 /home/alice /home/alice/.ssh
chown nobody:nogroup /home/alice/.ssh/authorized_keys
chmod 0644 /home/alice/.ssh/authorized_keys
