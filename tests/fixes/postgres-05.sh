#!/usr/bin/env bash
# Эталонное решение postgres-05 (для tests/selftest.sh)
set -euo pipefail
. "$(dirname "$0")/../../lib/common.sh"
uuid=$(disk_uuid "$(disk_dev pg05)")
sed -i -E "s|^UUID=\S+(\s+/srv/pgdata\s)|UUID=$uuid\1|" /etc/fstab
systemctl daemon-reload
mount /srv/pgdata
chown -R postgres:postgres /srv/pgdata/orders
chmod 700 /srv/pgdata/orders
pg_ctlcluster "$(pg_ver)" orders start
