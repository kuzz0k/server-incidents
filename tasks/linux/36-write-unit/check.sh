#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-36
. "$(dirname "$0")/../../../lib/check.sh"

U=notes-api
prop() { systemctl show -p "$1" --value "$U"; }
runs_as_notes() { local pid; pid=$(prop MainPID); [[ $pid != 0 && $(ps -o user= -p "$pid") == notes ]]; }
env_file() { prop EnvironmentFiles | grep -q '/etc/notes-api/notes-api.env'; }
restart_policy() { [[ $(prop Restart) =~ ^(on-failure|always)$ ]]; }
restart_sec() {
  python3 - "$(prop RestartUSec)" <<'PY'
import re, sys
mult = {"us": 1e-6, "ms": 1e-3, "s": 1, "min": 60, "h": 3600}
parts = re.findall(r"([0-9.]+)\s*(us|ms|min|s|h)?", sys.argv[1])
total = sum(float(n) * mult[u or "s"] for n, u in parts)
sys.exit(0 if parts and total <= 5 else 1)
PY
}
survives_kill() {
  local pid; pid=$(prop MainPID); [[ $pid != 0 ]] || return 1
  kill -9 "$pid"
  wait_until 10 bash -c "p=\$(systemctl show -p MainPID --value $U); [[ \$p != 0 && \$p != $pid ]] && curl -fs -o /dev/null http://127.0.0.1:8036/health"
}

check "notes-api активен" systemctl is-active -q "$U"
check "notes-api включён" systemctl is-enabled -q "$U"
check "процесс работает от notes" runs_as_notes
check "EnvironmentFile=/etc/notes-api/notes-api.env" env_file
check_http "GET :8036/health → 200 (данные пишутся)" 200 http://127.0.0.1:8036/health
check "Restart=on-failure или always" restart_policy
check "RestartSec ≤ 5 с" restart_sec
check "после kill -9 сервис поднимается сам" survives_kill
finish
