#!/usr/bin/env bash
set -uo pipefail
TASK_ID=postgres-05
. "$(dirname "$0")/../../../lib/check.sh"

V=$(pg_ver)
MP=/srv/pgdata
dev=$(disk_dev pg05)
online() { pg_lsclusters --no-header 2>/dev/null | awk '$2 == "orders"' | grep -q online; }
rows() { [[ $(cd / && sudo -u postgres psql -XqAt -p 5433 -d orders -c 'select count(*) from orders' 2>/dev/null) == 300 ]]; }
mounted_right() { [[ -n $dev && $(findmnt -n -o SOURCE "$MP") == "$dev" ]]; }
fstab_ok() {
  local line; line=$(awk -v mp="$MP" '$1 !~ /^#/ && $2 == mp' /etc/fstab)
  [[ $(grep -c . <<<"$line") -eq 1 ]] && grep -q "^UUID=$(disk_uuid "$dev") " <<<"$line" && awk '{print $4}' <<<"$line" | tr ',' '\n' | grep -qx nofail
}
perms() { [[ $(stat -c '%U %a' "$MP/orders") =~ ^postgres\ (700|750)$ ]]; }

check "кластер orders online" online
check "в orders 300 заказов" rows
check "$MP смонтирован с диска pgdata" mounted_right
check "в fstab одна запись по верному UUID с nofail" fstab_ok
check "каталог данных: владелец postgres, права 700/750" perms
finish
