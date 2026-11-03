#!/usr/bin/env bash
# linux-32: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-32
. "$(dirname "$0")/../../../lib/common.sh"

rm -rf /srv/shop
exit 0
