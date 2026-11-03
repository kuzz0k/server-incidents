#!/usr/bin/env bash
# linux-04: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-04
. "$(dirname "$0")/../../../lib/common.sh"

unmount_task "$TASK_ID" /data /backup
# записи, которые мог дописать решающий (break гарантирует, что своих у системы не было)
sed -i -E '/^[^#]\S*\s+\/(data|backup)\s/d' /etc/fstab
systemctl daemon-reload
remove_disk linux04-data
remove_disk linux04-backup
rmdir_empty /data /backup
exit 0
