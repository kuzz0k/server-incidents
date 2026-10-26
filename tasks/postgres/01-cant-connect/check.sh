#!/usr/bin/env bash
set -uo pipefail
TASK_ID=postgres-01
. "$(dirname "$0")/../../../lib/check.sh"

D=$(pg_dir)
IP=$(primary_ip)
count_via() { [[ $(PGPASSWORD=Shop-Pass-2026 PGCONNECT_TIMEOUT=5 psql -X -qAt -h "$1" -U shop -d shopdb -c 'select count(*) from shop.orders' 2>/dev/null) == 100 ]]; }
no_trust() { ! grep -Eq '^\s*host\S*\s.*\strust(\s|$)' "$D/pg_hba.conf"; }

check "shop читает shop.orders по $IP" count_via "$IP"
check "shop читает shop.orders по 127.0.0.1" count_via 127.0.0.1
check "в host-строках pg_hba нет trust" no_trust
check "shop не суперпользователь" bash -c "[[ \$(cd / && sudo -u postgres psql -XqAt -c \"select rolsuper from pg_roles where rolname='shop'\") == f ]]"
check "shop не владелец shopdb" bash -c "[[ \$(cd / && sudo -u postgres psql -XqAt -c \"select pg_get_userbyid(datdba) from pg_database where datname='shopdb'\") != shop ]]"
finish
