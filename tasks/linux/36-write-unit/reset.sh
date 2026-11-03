#!/usr/bin/env bash
# linux-36: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-36
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit notes-api
remove_user notes
remove_group notes
rm -rf /opt/notes-api /etc/notes-api /var/lib/notes-api /var/lib/private/notes-api
exit 0
