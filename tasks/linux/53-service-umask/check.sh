#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-53
. "$(dirname "$0")/../../../lib/check.sh"

D=/srv/reports
files_ok() {
  local f m n=0
  for f in "$D"/report-*.txt; do
    [[ -e $f ]] || continue
    n=$((n + 1)); m=8#$(stat -c %a "$f")
    (( (m & 8#040) && !(m & 8#004) )) || return 1
  done
  (( n > 0 ))
}
umask_ok() { local u; u=8#$(systemctl show -p UMask --value report-exporter); (( !(u & 8#040) && (u & 8#004) )); }
users_kept() { [[ $(systemctl show -p User --value report-exporter) == exporter && $(systemctl show -p User --value reports-web) == www-reports ]]; }

sleep 3
check_http "GET :8053/latest → 200" 200 http://127.0.0.1:8053/latest
check "отчёты читаются группой и не читаются прочими" files_ok
check "UMask report-exporter: группа читает, прочие нет" umask_ok
check "сервисы работают от своих пользователей" users_kept
finish
