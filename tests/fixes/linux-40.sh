#!/usr/bin/env bash
# Эталонное решение linux-40 (для tests/selftest.sh): скрипт из SOLUTION.md
set -euo pipefail
sed -n '/^```bash$/,/^```$/p' "$(dirname "$0")/../../tasks/linux/40-disk-alert-script/SOLUTION.md" | sed -n '1,/^```$/p' | sed '1d;$d' > /usr/local/bin/disk-alert.sh
chmod 755 /usr/local/bin/disk-alert.sh
echo '*/5 * * * * root /usr/local/bin/disk-alert.sh >/dev/null 2>&1' > /etc/cron.d/disk-alert
