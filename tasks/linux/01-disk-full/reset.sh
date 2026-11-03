#!/usr/bin/env bash
# linux-01: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-01
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit reports
unmount_task "$TASK_ID" /var/lib/reports
remove_disk linux01
remove_user reports
rm -rf /var/lib/reports
exit 0
