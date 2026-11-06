#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-46
. "$(dirname "$0")/../../../lib/common.sh"

MP=/srv/ci
ensure_pkgs quota
install_webapp
remove_unit ci-runner
quotaoff "$MP" >/dev/null 2>&1 || true
unmount_task "$TASK_ID" "$MP"
dev=$(make_disk linux46 400)
mkfs.ext4 -q -F -L ci -O quota -E quotatype=usrquota "$dev"
mkdir -p "$MP"
fstab_clear "$TASK_ID"
fstab_add "$TASK_ID" "UUID=$(disk_uuid "$dev") $MP ext4 defaults,usrquota,nofail,x-systemd.device-timeout=10s 0 2"
modprobe quota_v2 2>/dev/null || true
if ! mount "$MP"; then
  fstab_clear "$TASK_ID"; remove_disk linux46
  die "Ядро не поддерживает квоты ext4 (нет модуля quota_v2). Поставь: apt install linux-modules-extra-$(uname -r) и перезагрузись"
fi
quotaon "$MP" >/dev/null 2>&1 || true
ensure_user builder
mkdir -p "$MP/artifacts" "$MP/workspace"
for i in 1 2 3 4 5; do head -c 9M /dev/urandom > "$MP/artifacts/build-$((100 + i)).tar"; done
(cd "$MP/artifacts" && sha256sum ./*.tar) > "$TASK_VAR/artifacts.sha256"
chown -R builder: "$MP/artifacts" "$MP/workspace"
setquota -u builder 46080 51200 0 0 "$MP"

write_unit ci-runner <<EOF
[Unit]
Description=CI runner
After=network.target

[Service]
User=builder
Environment=NAME=ci-runner PORT=8046 DATA_DIR=$MP/workspace
ExecStart=/usr/bin/python3 $WEBAPP
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now ci-runner >/dev/null 2>&1
wait_for_port 8046
# Последняя сборка добила квоту
sudo -u builder dd if=/dev/zero of="$MP/workspace/build-106.tmp" bs=1M count=10 status=none 2>/dev/null || true
