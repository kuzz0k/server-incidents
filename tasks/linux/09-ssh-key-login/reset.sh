#!/usr/bin/env bash
# linux-09: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-09
. "$(dirname "$0")/../../../lib/common.sh"

remove_user alice
rm -rf /root/trainer-keys
exit 0
