#!/usr/bin/env bash
# linux-13: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-13
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit catalog
remove_user catalog
rm -rf /etc/catalog
exit 0
