#!/usr/bin/env bash
# linux-29: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-29
. "$(dirname "$0")/../../../lib/common.sh"

rm -f /var/log/trainer/access.log
rmdir_empty /var/log/trainer
exit 0
