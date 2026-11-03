#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-40
. "$(dirname "$0")/../../../lib/common.sh"

save_original /usr/local/bin/disk-alert.sh     # trainer reset вернёт исходный вариант
rm -f /usr/local/bin/disk-alert.sh
rm -f /etc/cron.d/disk-alert
