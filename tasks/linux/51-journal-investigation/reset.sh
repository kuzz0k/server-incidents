#!/usr/bin/env bash
# linux-51: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-51
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit payment-gw
rm -rf /var/lib/payment-gw "$TRAINER_LIB/payment-gw.py"
exit 0
