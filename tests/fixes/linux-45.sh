#!/usr/bin/env bash
# Эталонное решение linux-45 (для tests/selftest.sh)
set -euo pipefail
. "$(dirname "$0")/../../lib/common.sh"
dev=$(disk_dev linux45)
systemctl stop uploads-api
umount /srv/uploads
e2fsck -f -y "$dev" >/dev/null || true     # код 1 = ошибки исправлены
mount /srv/uploads
systemctl start uploads-api
sleep 2
