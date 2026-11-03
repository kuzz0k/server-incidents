#!/usr/bin/env bash
# linux-30: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-30
. "$(dirname "$0")/../../../lib/common.sh"

remove_cron_refs backup-app.sh
restore_original /usr/local/bin/backup-app.sh
rm -rf /srv/app-data /var/backups/app-data "/tmp/trainer src" "/tmp/trainer dst" /tmp/trainer-dst-missing
exit 0
