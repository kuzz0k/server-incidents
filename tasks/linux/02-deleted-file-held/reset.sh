#!/usr/bin/env bash
# linux-02: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-02
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit metrics-agent
unmount_task "$TASK_ID" /var/lib/metrics
remove_disk linux02
remove_user metrics
rm -rf /var/lib/metrics "$TRAINER_LIB/metrics-agent.py"
exit 0
