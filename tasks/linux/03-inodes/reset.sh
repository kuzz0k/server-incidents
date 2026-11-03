#!/usr/bin/env bash
# linux-03: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-03
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit sessions
unmount_task "$TASK_ID" /var/lib/sessions
remove_disk linux03
remove_user sessions
rm -rf /var/lib/sessions
exit 0
