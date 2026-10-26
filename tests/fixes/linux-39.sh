#!/usr/bin/env bash
# Эталонное решение linux-39 (для tests/selftest.sh)
set -euo pipefail
. "$(dirname "$0")/../../lib/common.sh"
ensure_pkgs jq
F=/srv/inventory/servers.json
mkdir -p /root/answers
{
  echo "down_count=$(jq '[.[] | select(.status == "down")] | length' $F)"
  echo "hot_msk1=$(jq -r '[.[] | select(.dc == "msk-1" and .cpu_load > 80) | .name] | sort | join(",")' $F)"
  echo "top_dc=$(jq -r '[.[] | select(.status == "up")] | group_by(.dc) | max_by(length) | .[0].dc' $F)"
  echo "db_tagged=$(jq '[.[] | select(.tags | index("db"))] | length' $F)"
} > /root/answers/linux-39.txt
{ echo "name,dc,ip,status"; jq -r 'sort_by(.name)[] | [.name, .dc, .ip, .status] | join(",")' $F; } > /root/answers/linux-39.csv
