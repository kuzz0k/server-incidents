#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-04
. "$(dirname "$0")/../../../lib/common.sh"

fstab_clear "$TASK_ID"
if awk '$1 !~ /^#/ && ($2 == "/data" || $2 == "/backup")' /etc/fstab | grep -q .; then
  die "В /etc/fstab уже есть свои записи для /data или /backup — задача их не трогает. Запусти её на чистой VM."
fi
unmount_task "$TASK_ID" /data /backup

prepare() {
  local name=$1 dev
  dev=$(make_disk "linux04-$name" 100)
  mkfs.ext4 -q -F -L "$name" "$dev"
  mkdir -p "/$name"
  mount "$dev" "/$name"
  echo "disk=$name" > "/$name/.disk-id"
  head -c 5M /dev/urandom > "/$name/$name-2026-10.bin"
  umount "/$name"
  echo "$dev"
}

prepare data >/dev/null
backup_dev=$(prepare backup)
old_uuid=$(cat /proc/sys/kernel/random/uuid)

fstab_add "$TASK_ID" \
  "UUID=$old_uuid /data ext4 defaults,nofail 0 2" \
  "UUID=$(disk_uuid "$backup_dev") /backup ext4 defualts,nofail 0 2"
