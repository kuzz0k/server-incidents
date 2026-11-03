#!/usr/bin/env bash
# linux-33: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-33
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit report-sync
rm -f /var/log/trainer/bad.log "$TRAINER_LIB/report-sync.py"
rmdir_empty /var/log/trainer
exit 0
