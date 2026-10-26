#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-35
. "$(dirname "$0")/../../../lib/check.sh"

LOG=/var/log/healthcheck.log
before=$(grep -c 'STATUS: OK' "$LOG" 2>/dev/null || echo 0)

every_minute() {
  local spec times a b
  spec=$(systemctl show -p TimersCalendar --value healthcheck.timer | sed -n 's/.*OnCalendar=\([^;]*\);.*/\1/p' | sed 's/[[:space:]]*$//')
  [[ -n $spec ]] || return 1
  mapfile -t times < <(systemd-analyze calendar --iterations=3 "$spec" 2>/dev/null | sed -n 's/^.*\(Next elapse\|Iter[a-z.]* #[0-9]*\): *//p' | head -3)
  ((${#times[@]} >= 2)) || return 1
  a=$(date -d "${times[0]}" +%s) b=$(date -d "${times[1]}" +%s)
  (( b - a <= 60 ))
}
new_line() { (( $(grep -c 'STATUS: OK' "$LOG" 2>/dev/null || echo 0) > before )); }

check "healthcheck.timer активен" systemctl is-active -q healthcheck.timer
check "healthcheck.timer включён" systemctl is-enabled -q healthcheck.timer
check "расписание — не реже раза в минуту" every_minute
echo "  Жду срабатывания таймера (до 90 с)…"
wait_until 90 new_line
check "в логе появилась новая строка STATUS: OK" new_line
finish
