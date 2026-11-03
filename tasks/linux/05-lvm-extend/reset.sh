#!/usr/bin/env bash
# linux-05: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-05
. "$(dirname "$0")/../../../lib/common.sh"

mountpoint -q /srv/app && { umount /srv/app 2>/dev/null || umount -l /srv/app; }
fstab_clear "$TASK_ID"
sed -i -E '/^[^#]\S*\s+\/srv\/app\s/d' /etc/fstab
systemctl daemon-reload
if vgs vgapp >/dev/null 2>&1; then
  lvremove -qq -fy vgapp >/dev/null 2>&1
  vgremove -qq -fy vgapp >/dev/null 2>&1
fi
for n in a b c; do
  dev=$(disk_dev "linux05-$n" 2>/dev/null)
  [[ -n $dev ]] && pvremove -qq -ffy "$dev" >/dev/null 2>&1
  remove_disk "linux05-$n"
done
rmdir_empty /srv/app
exit 0
