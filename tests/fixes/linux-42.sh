#!/usr/bin/env bash
# Эталонное решение linux-42 (для tests/selftest.sh)
set -euo pipefail
printf '[Journal]\nStorage=persistent\nSystemMaxUse=150M\nSystemKeepFree=1G\n' > /etc/systemd/journald.conf.d/90-retention.conf
systemctl restart systemd-journald
journalctl --rotate >/dev/null
journalctl --vacuum-size=150M >/dev/null
