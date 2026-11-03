#!/usr/bin/env bash
# linux-07: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-07
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit inventory
remove_user inventory
rm -rf /etc/inventory /var/lib/inventory
exit 0
