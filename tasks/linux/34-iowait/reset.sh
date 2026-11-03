#!/usr/bin/env bash
# linux-34: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-34
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit search-reindex
unmount_task "$TASK_ID" /var/lib/reindex
remove_disk linux34
rmdir_empty /var/lib/reindex
exit 0
