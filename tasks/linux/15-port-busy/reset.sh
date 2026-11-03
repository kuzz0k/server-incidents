#!/usr/bin/env bash
# linux-15: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-15
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit gateway legacy-gw
remove_user gateway
rm -rf /opt/legacy-gw
exit 0
