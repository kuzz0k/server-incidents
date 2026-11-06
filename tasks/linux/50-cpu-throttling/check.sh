#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-50
. "$(dirname "$0")/../../../lib/check.sh"

U=pricing-api
fast() {
  local t
  t=$(curl -s -o /dev/null -w '%{http_code} %{time_total}' --max-time 10 http://127.0.0.1:8050/price) || return 1
  [[ ${t% *} == 200 ]] && python3 -c "import sys; sys.exit(0 if float('${t#* }') < 1.5 else 1)"
}
quota_ok() {
  local v; v=$(systemctl show -p CPUQuotaPerSecUSec --value "$U")
  python3 - "$v" <<'PY'
import re, sys
v = sys.argv[1]
m = re.fullmatch(r"([0-9.]+)(us|ms|s)", v)
if not m:
    sys.exit(1)
sec = float(m.group(1)) * {"us": 1e-6, "ms": 1e-3, "s": 1}[m.group(2)]
sys.exit(0 if 0.3 <= sec <= 1.0 else 1)
PY
}

check "GET /price → 200 быстрее 1,5 с" fast
check "CPUQuota от 30% до 100%" quota_ok
check "CPUQuota задан через drop-in" bash -c "grep -qs '^CPUQuota=' /etc/systemd/system/$U.service.d/*.conf"
finish
