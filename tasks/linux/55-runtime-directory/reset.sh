#!/usr/bin/env bash
# linux-55: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-55
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit sessiond
grep -lsF '/run/sessiond' /etc/tmpfiles.d/*.conf | xargs -r rm -f
rm -rf /run/sessiond
remove_user sessiond
remove_group sessiond
exit 0
