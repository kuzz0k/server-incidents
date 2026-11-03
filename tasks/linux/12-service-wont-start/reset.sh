#!/usr/bin/env bash
# linux-12: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-12
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit orders
remove_user orders
rm -rf /etc/default/orders /etc/orders
exit 0
