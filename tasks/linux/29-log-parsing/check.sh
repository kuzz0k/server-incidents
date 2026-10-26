#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-29
. "$(dirname "$0")/../../../lib/check.sh"

LOG=/var/log/trainer/access.log
mapfile -t top < <(awk '{print $1}' "$LOG" | sort | uniq -c | sort -rn | head -3 | awk '{print $2}')
e5xx=$(awk '$9 ~ /^5[0-9][0-9]$/' "$LOG" | wc -l)
u404=$(awk '$9 == 404 {print $7}' "$LOG" | sort | uniq -c | sort -rn | head -1 | awk '{print $2}')
u14=$(awk '{split($4, t, ":"); if (t[2] == "14") print $1}' "$LOG" | sort -u | wc -l)

check "файл ответов существует" test -f "$(answers_file)"
check "top_ip1" answer_is top_ip1 "${top[0]}"
check "top_ip2" answer_is top_ip2 "${top[1]}"
check "top_ip3" answer_is top_ip3 "${top[2]}"
check "errors_5xx" answer_is errors_5xx "$e5xx"
check "top_404_url" answer_is top_404_url "$u404"
check "unique_ips_14h" answer_is unique_ips_14h "$u14"
finish
