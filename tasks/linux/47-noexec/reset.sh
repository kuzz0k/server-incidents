#!/usr/bin/env bash
# linux-47: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-47
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit cache-rotate
unmount_task "$TASK_ID" /srv/tools
sed -i -E '/^[^#]\S*\s+\/srv\/tools\s/d' /etc/fstab
systemctl daemon-reload
remove_disk linux47
rm -f /var/log/cache-rotate.log
rmdir_empty /srv/tools
exit 0
