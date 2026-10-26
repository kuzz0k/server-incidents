#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-34
. "$(dirname "$0")/../../../lib/common.sh"

MP=/var/lib/reindex
remove_unit search-reindex
unmount_task "$TASK_ID" "$MP"
dev=$(make_disk linux34 1200)
mkfs.ext4 -q -F -L reindex "$dev"
mount_disk "$TASK_ID" "$dev" "$MP"

write_unit search-reindex <<EOF
[Unit]
Description=Search index rebuild
After=network.target

[Service]
ExecStart=/bin/bash -c 'while true; do dd if=/dev/zero of=$MP/segment.bin bs=1M count=512 oflag=direct status=none; done'
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now search-reindex >/dev/null 2>&1
