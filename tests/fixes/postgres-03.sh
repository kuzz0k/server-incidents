#!/usr/bin/env bash
# Эталонное решение postgres-03 (для tests/selftest.sh)
set -euo pipefail
dump=$(ls /var/backups/postgres/crm-*.dump | head -1)
pg_restore -l "$dump" | grep -E '\sdeals(_|\s|$)' > /tmp/deals.list
(cd / && sudo -u postgres pg_restore -d crm -L /tmp/deals.list "$dump")
rm -f /tmp/deals.list
