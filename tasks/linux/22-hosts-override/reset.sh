#!/usr/bin/env bash
# linux-22: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-22
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit payments-api
remove_user payments
hosts_drop 'api\.payments\.internal|^# payments API$'
exit 0
