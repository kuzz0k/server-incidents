#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-40
. "$(dirname "$0")/../../../lib/common.sh"

if [[ -f /usr/local/bin/disk-alert.sh ]]; then
  mv /usr/local/bin/disk-alert.sh "/usr/local/bin/disk-alert.sh.bak-$(date +%s)"
  warn "Старый /usr/local/bin/disk-alert.sh сохранён рядом как .bak"
fi
rm -f /etc/cron.d/disk-alert
