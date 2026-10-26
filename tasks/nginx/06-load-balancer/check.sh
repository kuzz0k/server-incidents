#!/usr/bin/env bash
set -uo pipefail
TASK_ID=nginx-06
. "$(dirname "$0")/../../../lib/check.sh"

all_ok() {
  local i
  for i in $(seq 30); do [[ $(http_code http://127.0.0.1:8106/) == 200 ]] || return 1; done
}
report_ok() { [[ $(curl -s -o /dev/null -w '%{http_code}' --max-time 30 http://127.0.0.1:8106/report) == 200 ]]; }
c_kept() { nginx -T 2>/dev/null | grep -Eq '^\s*server\s+127\.0\.0\.1:9163'; }

check "nginx -t без ошибок" nginx -t
check "30 запросов к / — все 200" all_ok
check "GET /report → 200" report_ok
check "shop-c (9163) остался в upstream" c_kept
check "shop-c по-прежнему выключен (бэкенды не трогали)" bash -c "! systemctl is-active -q shop-c"
finish
