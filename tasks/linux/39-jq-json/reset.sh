#!/usr/bin/env bash
# linux-39: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-39
. "$(dirname "$0")/../../../lib/common.sh"

rm -rf /srv/inventory
exit 0
