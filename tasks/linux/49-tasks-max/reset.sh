#!/usr/bin/env bash
# linux-49: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-49
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit job-runner
rm -f "$TRAINER_LIB/job-runner.py"
exit 0
