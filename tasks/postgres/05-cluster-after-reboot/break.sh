#!/usr/bin/env bash
set -euo pipefail
TASK_ID=postgres-05
. "$(dirname "$0")/../../../lib/common.sh"

V=$(pg_ver)
MP=/srv/pgdata
pg_ctlcluster "$V" orders stop >/dev/null 2>&1 || true
pg_dropcluster "$V" orders >/dev/null 2>&1 || rm -rf "/etc/postgresql/$V/orders"
systemctl reset-failed "postgresql@$V-orders" >/dev/null 2>&1 || true
unmount_task "$TASK_ID" "$MP"
dev=$(make_disk pg05 600)
mkfs.ext4 -q -F -L pgdata "$dev"
mkdir -p "$MP"
mount "$dev" "$MP"
install -d -o postgres -g postgres -m 0700 "$MP/orders"
pg_createcluster "$V" orders -d "$MP/orders" -p 5433 --start >/dev/null
(cd / && sudo -u postgres psql -X -q -p 5433 -v ON_ERROR_STOP=1) <<'SQL'
CREATE DATABASE orders;
\c orders
CREATE TABLE orders (id serial PRIMARY KEY, customer text, total numeric(10,2));
INSERT INTO orders (customer, total) SELECT 'c' || g, g * 1.5 FROM generate_series(1, 300) g;
SQL
pg_ctlcluster "$V" orders stop
chown -R root:root "$MP/orders"
chmod 0755 "$MP/orders"
umount "$MP"
fstab_add "$TASK_ID" "UUID=$(cat /proc/sys/kernel/random/uuid) $MP ext4 defaults,nofail 0 2"
pg_ctlcluster "$V" orders start >/dev/null 2>&1 || true
