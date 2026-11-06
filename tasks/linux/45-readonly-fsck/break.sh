#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-45
. "$(dirname "$0")/../../../lib/common.sh"

MP=/srv/uploads
install_webapp
remove_unit uploads-api
unmount_task "$TASK_ID" "$MP"
dev=$(make_disk linux45 200)
mkfs.ext4 -q -F -L uploads "$dev"
mount_disk "$TASK_ID" "$dev" "$MP"
ensure_user uploads
mkdir -p "$MP/data"
for i in 1 2 3 4; do head -c 3M /dev/urandom > "$MP/data/batch-$i.dat"; done
(cd "$MP/data" && sha256sum ./*.dat) > "$TASK_VAR/data.sha256"
head -c 1M /dev/urandom > "$MP/data/upload-in-progress.tmp"
chown -R uploads: "$MP"
disk_uuid "$dev" > "$TASK_VAR/uuid"
umount "$MP"

# «Сбой»: повреждённый inode и отметка об ошибках в суперблоке
debugfs -w -R "clri /data/upload-in-progress.tmp" "$dev" >/dev/null 2>&1
tune2fs -e remount-ro "$dev" >/dev/null
debugfs -w -R "ssv state 2" "$dev" >/dev/null 2>&1
mount -o ro "$dev" "$MP"

write_unit uploads-api <<EOF
[Unit]
Description=Uploads API
After=network.target

[Service]
User=uploads
Environment=NAME=uploads-api PORT=8045 DATA_DIR=$MP/data
ExecStart=/usr/bin/python3 $WEBAPP
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now uploads-api >/dev/null 2>&1
wait_for_port 8045
