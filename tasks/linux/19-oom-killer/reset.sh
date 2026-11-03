#!/usr/bin/env bash
# linux-19: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-19
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit imagecache
remove_user imagecache
rm -f /etc/imagecache.conf
exit 0
