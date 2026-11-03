#!/usr/bin/env bash
# linux-20: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-20
. "$(dirname "$0")/../../../lib/common.sh"

remove_cron_refs db-backup.sh
rm -f /etc/cron.d/db-backup /etc/cron.d/db-backup.cron
rm -rf /opt/backup /var/backups/db /var/lib/fake-db
rm -f /var/log/db-backup-*.log
exit 0
