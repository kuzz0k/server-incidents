#!/usr/bin/env bash
# linux-48: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-48
. "$(dirname "$0")/../../../lib/common.sh"

pid=$(systemctl show -p MainPID --value quotes-api 2>/dev/null)
[[ -n $pid && $pid != 0 ]] && kill -CONT "$pid" 2>/dev/null
remove_unit quotes-api
exit 0
