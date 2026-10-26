#!/usr/bin/env bash
set -uo pipefail
TASK_ID=postgres-02
. "$(dirname "$0")/../../../lib/check.sh"

Q="SELECT id, type, created_at FROM events WHERE user_id = 4242 AND created_at > now() - interval '30 days' ORDER BY created_at DESC LIMIT 20"
psql_su -d analytics -c "$Q" >/dev/null 2>&1   # прогрев кеша
plan=$(psql_su -d analytics -c "EXPLAIN (ANALYZE) $Q" 2>/dev/null)
ms=$(sed -n 's/.*Execution Time: \([0-9.]*\) ms.*/\1/p' <<<"$plan" | cut -d. -f1)

no_seq_scan() { [[ -n $plan ]] && ! grep -q 'Seq Scan on events' <<<"$plan"; }
uses_index() { grep -q 'Index' <<<"$plan"; }
fast() { [[ -n $ms ]] && (( ms < 20 )); }

check "в плане нет Seq Scan по events" no_seq_scan
check "используется индекс" uses_index
check "запрос быстрее 20 мс (сейчас ${ms:-?} мс)" fast
check "analytics-dashboard работает" systemctl is-active -q analytics-dashboard
finish
