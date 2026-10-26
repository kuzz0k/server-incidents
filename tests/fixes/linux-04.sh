#!/usr/bin/env bash
# Эталонное решение linux-04 (для tests/selftest.sh)
set -euo pipefail
. "$(dirname "$0")/../../lib/common.sh"
uuid=$(disk_uuid "$(disk_dev linux04-data)")
sed -i -E "s|^UUID=\S+(\s+/data\s)|UUID=$uuid\1|" /etc/fstab
sed -i 's/defualts/defaults/' /etc/fstab
systemctl daemon-reload
mount -a
