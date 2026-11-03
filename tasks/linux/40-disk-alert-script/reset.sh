#!/usr/bin/env bash
# linux-40: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-40
. "$(dirname "$0")/../../../lib/common.sh"

remove_cron_refs disk-alert
grep -ls disk-alert /etc/systemd/system/*.timer /etc/systemd/system/*.service 2>/dev/null \
  | while read -r u; do remove_unit "$(basename "$u")"; done
restore_original /usr/local/bin/disk-alert.sh
umount -l /mnt/trainer-alert /mnt/trainer-tmpfs 2>/dev/null
remove_disk linux40
rmdir_empty /mnt/trainer-alert /mnt/trainer-tmpfs
exit 0
