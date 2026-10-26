#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-43
. "$(dirname "$0")/../../../lib/check.sh"

D=/var/log/app-cleaner
bash "$(dirname "$0")/fixture.sh"
check "скрипт отрабатывает из чужого каталога" bash -c "cd /tmp && /usr/local/bin/clean-logs.sh"
for f in "api.log" "worker today.log" "README.txt" "api-recent.log.gz" "api-week.log.gz"; do
  check "не тронут: $f" test -f "$D/$f"
done
for f in "api-old.log" "worker 2026-old.log" "billing.log"; do
  check "сжат: $f" bash -c "[[ ! -e '$D/$f' && -f '$D/$f.gz' ]]"
done
for f in "api-ancient.log.gz" "worker old 2.log.gz"; do
  check "удалён: $f" test ! -e "$D/$f"
done
check "других файлов не появилось" bash -c "[[ \$(ls -A $D | wc -l) -eq 8 ]]"
finish
