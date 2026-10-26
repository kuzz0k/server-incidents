#!/usr/bin/env bash
# Эталонное решение linux-43 (для tests/selftest.sh): скрипт из SOLUTION.md
set -euo pipefail
sed -n '/^## Исправленный скрипт$/,$p' "$(dirname "$0")/../../tasks/linux/43-log-cleaner/SOLUTION.md" \
  | sed -n '/^```bash$/,/^```$/p' | sed '1d;$d' > /usr/local/bin/clean-logs.sh
chmod 755 /usr/local/bin/clean-logs.sh
