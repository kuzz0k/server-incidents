#!/usr/bin/env bash
# linux-45: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-45
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit uploads-api
unmount_task "$TASK_ID" /srv/uploads
remove_disk linux45
remove_user uploads
rmdir_empty /srv/uploads
exit 0
