#!/usr/bin/env bash
# Эталонное решение linux-56 (для tests/selftest.sh)
set -euo pipefail
sysctl -qw fs.inotify.max_user_watches=524288
echo 'fs.inotify.max_user_watches=524288' > /etc/sysctl.d/90-inotify.conf
systemctl reset-failed file-sync || true
systemctl restart file-sync
sleep 3
