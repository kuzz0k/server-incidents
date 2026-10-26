#!/usr/bin/env bash
set -uo pipefail
TASK_ID=postgres-03
. "$(dirname "$0")/../../../lib/check.sh"

q() { psql_su -d crm -c "$1" 2>/dev/null; }
deals_match() { [[ $(q "SELECT count(*) || ' ' || sum(amount) FROM deals") == "$(cat "$TASK_VAR/deals.expected")" ]]; }
constraints() { [[ $(q "SELECT string_agg(contype::text, '' ORDER BY contype) FROM pg_constraint WHERE conrelid = 'deals'::regclass AND contype IN ('p', 'f')") == fp ]]; }

check "deals: количество строк и сумма как в бэкапе" deals_match
check "customers: 525 клиентов (старые + новые)" bash -c "[[ \$(cd / && sudo -u postgres psql -XqAt -d crm -c 'select count(*) from customers') == 525 ]]"
check "у deals есть PRIMARY KEY и FOREIGN KEY" constraints
finish
