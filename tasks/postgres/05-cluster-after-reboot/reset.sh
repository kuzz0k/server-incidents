#!/usr/bin/env bash
# postgres-05: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=postgres-05
. "$(dirname "$0")/../../../lib/common.sh"

V=$(pg_ver)
pg_ctlcluster "$V" orders stop >/dev/null 2>&1
pg_dropcluster "$V" orders >/dev/null 2>&1
rm -rf "/etc/postgresql/$V/orders" /etc/systemd/system/postgresql@*-orders.service.d
systemctl reset-failed "postgresql@$V-orders" >/dev/null 2>&1
unmount_task "$TASK_ID" /srv/pgdata
sed -i -E '/^[^#]\S*\s+\/srv\/pgdata\s/d' /etc/fstab
systemctl daemon-reload
remove_disk pg05
rmdir_empty /srv/pgdata
exit 0
