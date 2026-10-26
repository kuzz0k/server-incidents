#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-01
. "$(dirname "$0")/../../../lib/common.sh"

MP=/var/lib/reports

install_webapp
remove_unit reports
unmount_task "$TASK_ID" "$MP"
dev=$(make_disk linux01 300)
mkfs.ext4 -q -F -L reports "$dev"
mount_disk "$TASK_ID" "$dev" "$MP"
ensure_user reports

mkdir -p "$MP"/{data,logs,tmp}
for m in 07 08 09; do head -c 5M /dev/urandom > "$MP/data/reports-2026-$m.db"; done
(cd "$MP/data" && sha256sum ./*.db) > "$TASK_VAR/data.sha256"
for i in $(seq 1 8); do head -c 6M /dev/urandom > "$MP/tmp/export-$i.tar.gz.tmp"; done
head -c 150M < <(yes "2026-10-21T03:14:15 DEBUG reports.render: cache miss template=monthly user_id=1842 took=12ms") > "$MP/logs/debug.log"
yes "2026-10-20T23:59:59 DEBUG reports.render: cache miss template=weekly user_id=77 took=9ms" > "$MP/logs/debug.log.1" 2>/dev/null || true
chown -R reports: "$MP"

write_unit reports <<EOF
[Unit]
Description=Reports service
After=network.target

[Service]
User=reports
Environment=NAME=reports PORT=8001 DATA_DIR=$MP/data
ExecStart=/usr/bin/python3 $WEBAPP
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now reports >/dev/null 2>&1
wait_for_port 8001
