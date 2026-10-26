#!/usr/bin/env bash
# Эталонное решение linux-30 (для tests/selftest.sh): скрипт из SOLUTION.md
set -euo pipefail
sed -n '/^```bash$/,/^```$/p' "$(dirname "$0")/../../tasks/linux/30-backup-script/SOLUTION.md" | sed '1d;$d' > /usr/local/bin/backup-app.sh
chmod 755 /usr/local/bin/backup-app.sh
