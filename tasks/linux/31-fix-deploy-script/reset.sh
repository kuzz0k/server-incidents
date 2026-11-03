#!/usr/bin/env bash
# linux-31: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-31
. "$(dirname "$0")/../../../lib/common.sh"

rm -rf /opt/deploy
exit 0
