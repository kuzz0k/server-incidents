#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-14
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit notifier
ensure_user notifier
write_unit notifier <<EOF
[Unit]
Description=Notification service
After=network-online.target
Wants=network-online.target

[Service]
User=notifier
Environment=NAME=notifier PORT=8014
ExecStart=/usr/bin/python3 $WEBAPP
Restart=on-failure
EOF
