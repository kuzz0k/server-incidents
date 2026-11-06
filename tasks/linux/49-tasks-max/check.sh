#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-49
. "$(dirname "$0")/../../../lib/check.sh"

U=job-runner
tasks_ok() { local n; n=$(systemctl show -p TasksCurrent --value "$U"); [[ $n =~ ^[0-9]+$ ]] && (( n >= 40 )); }
max_ok() { local m; m=$(systemctl show -p TasksMax --value "$U"); [[ $m == infinity ]] || (( m >= 64 )); }

check "job-runner активен и стабилен 5 с" service_stable "$U" 5
check_http "GET :8049/health → 200" 200 http://127.0.0.1:8049/health
check "у сервиса ≥ 40 задач (потоков)" tasks_ok
check "TasksMax ≥ 64 или infinity" max_ok
check "лимит задан через drop-in" bash -c "grep -qs '^TasksMax=' /etc/systemd/system/$U.service.d/*.conf"
check "WORKERS=40 не изменён" bash -c "systemctl show -p Environment --value $U | grep -qw WORKERS=40"
finish
