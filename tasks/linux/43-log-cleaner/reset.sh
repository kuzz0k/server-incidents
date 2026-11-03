#!/usr/bin/env bash
# linux-43: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-43
. "$(dirname "$0")/../../../lib/common.sh"

rm -f /usr/local/bin/clean-logs.sh
rm -rf /var/log/app-cleaner
exit 0
