#!/usr/bin/env bash
# linux-17: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-17
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit legacy-batch
rm -f "$TRAINER_LIB/legacy-batch.py"
exit 0
