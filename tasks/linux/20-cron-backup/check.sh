#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-20
. "$(dirname "$0")/../../../lib/check.sh"

marker=$(mktemp)
new_backup() { find /var/backups/db -name 'db-*.tar.gz' -newer "$marker" | grep -q .; }
in_cron_d() { grep -lqs 'db-backup.sh' /etc/cron.d/*; }

echo "  Жду, пока cron выполнит задание (до 150 с)…"
wait_until 150 new_backup
check "в /var/backups/db появился новый архив" new_backup
check "есть лог /var/log/db-backup-$(date +%F).log" test -f "/var/log/db-backup-$(date +%F).log"
check "задание лежит в /etc/cron.d" in_cron_d
rm -f "$marker"
finish
