#!/usr/bin/env bash
# linux-44: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-44
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit orders-api order-sync
rm -f /etc/default/order-sync "$TRAINER_LIB/order-sync.py"
exit 0
