#!/usr/bin/env bash
# Эталонное решение linux-14 (для tests/selftest.sh)
set -euo pipefail
printf '\n[Install]\nWantedBy=multi-user.target\n' >> /etc/systemd/system/notifier.service
systemctl daemon-reload
systemctl enable --now notifier
sleep 2
