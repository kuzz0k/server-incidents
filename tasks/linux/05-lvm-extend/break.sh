#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-05
. "$(dirname "$0")/../../../lib/common.sh"

MP=/srv/app

mountpoint -q "$MP" && umount -l "$MP"
fstab_clear "$TASK_ID"
if vgs vgapp >/dev/null 2>&1; then
  lvremove -qq -fy vgapp >/dev/null
  vgremove -qq -fy vgapp >/dev/null
fi
for n in a b c; do
  dev=$(disk_dev "linux05-$n" 2>/dev/null || true)
  [[ -n $dev ]] && pvremove -qq -ffy "$dev" >/dev/null 2>&1 || true
  remove_disk "linux05-$n"
done

da=$(make_disk linux05-a 200)
db=$(make_disk linux05-b 200)
make_disk linux05-c 400 >/dev/null
pvcreate -qq "$da" "$db" >/dev/null
vgcreate -qq vgapp "$da" "$db" >/dev/null
lvcreate -qq -y -l 100%FREE -n data vgapp >/dev/null
mkfs.ext4 -q -F -L appdata /dev/vgapp/data
mkdir -p "$MP"
fstab_add "$TASK_ID" "/dev/vgapp/data $MP ext4 defaults,nofail,x-systemd.device-timeout=10s 0 2"
mount "$MP"

mkdir -p "$MP/releases" "$MP/media"
i=0
while (( $(df --output=pcent "$MP" | tail -1 | tr -dc 0-9) < 94 )); do
  i=$((i + 1))
  head -c 20M /dev/urandom > "$MP/media/blob-$i.bin" 2>/dev/null || break
done
echo "release 3.4.1" > "$MP/releases/current"
(cd "$MP" && find . -type f -print0 | sort -z | xargs -0 sha256sum) > "$TASK_VAR/data.sha256"
