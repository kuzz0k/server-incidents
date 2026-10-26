#!/usr/bin/env bash
# shellcheck disable=SC2154  # down_count и др. задаёт eval ниже
set -uo pipefail
TASK_ID=linux-39
. "$(dirname "$0")/../../../lib/check.sh"

F=/srv/inventory/servers.json
eval "$(python3 - "$F" <<'EOF'
import collections, json, sys
s = json.load(open(sys.argv[1]))
up = collections.Counter(x["dc"] for x in s if x["status"] == "up")
print(f'down_count={sum(x["status"] == "down" for x in s)}')
print(f'hot_msk1={",".join(sorted(x["name"] for x in s if x["dc"] == "msk-1" and x["cpu_load"] > 80))}')
print(f'top_dc={up.most_common(1)[0][0]}')
print(f'db_tagged={sum("db" in x["tags"] for x in s)}')
EOF
)"
csv_ok() {
  diff -q <(tr -d '\r' < "$ANSWERS_DIR/linux-39.csv") \
    <(python3 -c "import json; s=json.load(open('$F')); print('name,dc,ip,status'); [print(','.join([x['name'],x['dc'],x['ip'],x['status']])) for x in sorted(s, key=lambda x: x['name'])]")
}

check "down_count" answer_is down_count "$down_count"
check "hot_msk1" answer_is hot_msk1 "$hot_msk1"
check "top_dc" answer_is top_dc "$top_dc"
check "db_tagged" answer_is db_tagged "$db_tagged"
check "CSV совпадает" csv_ok
finish
