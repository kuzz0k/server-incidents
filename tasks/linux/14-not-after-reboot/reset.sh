#!/usr/bin/env bash
# linux-14: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-14
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit notifier
remove_user notifier
exit 0
