#!/usr/bin/env bash
# linux-46: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-46
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit ci-runner
quotaoff /srv/ci >/dev/null 2>&1
unmount_task "$TASK_ID" /srv/ci
remove_disk linux46
remove_user builder
rmdir_empty /srv/ci
exit 0
