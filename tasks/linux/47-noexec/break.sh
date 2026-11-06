#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-47
. "$(dirname "$0")/../../../lib/common.sh"

MP=/srv/tools
remove_unit cache-rotate
rm -f /var/log/cache-rotate.log
unmount_task "$TASK_ID" "$MP"
dev=$(make_disk linux47 64)
mkfs.ext4 -q -F -L tools "$dev"
mkdir -p "$MP"
fstab_clear "$TASK_ID"
fstab_add "$TASK_ID" "UUID=$(disk_uuid "$dev") $MP ext4 defaults,nodev,nosuid,noexec,nofail,x-systemd.device-timeout=10s 0 2"
mount "$MP"
cat > "$MP/rotate-cache.sh" <<'EOF'
#!/bin/bash
# Ротация кеша: удаляет старые файлы кеша и пишет отметку в лог
find /var/cache/app-rotate -type f -mmin +60 -delete 2>/dev/null
echo "$(date -Is) cache rotated" >> /var/log/cache-rotate.log
EOF
chmod 0755 "$MP/rotate-cache.sh"

write_unit cache-rotate <<EOF
[Unit]
Description=Rotate application cache

[Service]
Type=oneshot
ExecStart=$MP/rotate-cache.sh
EOF
systemctl start cache-rotate >/dev/null 2>&1 || true
