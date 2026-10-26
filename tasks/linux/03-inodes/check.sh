#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-03
. "$(dirname "$0")/../../../lib/check.sh"

MP=/var/lib/sessions

fresh_present() {
  local n
  while read -r n; do
    [[ -z $n || -e $MP/store/$n ]] || return 1
  done < "$TASK_VAR/fresh.txt"
}

check "$MP смонтирован" mountpoint -q "$MP"
check "занято меньше 50% inode" bash -c "(( \$(df --output=ipcent $MP | tail -1 | tr -dc 0-9) < 50 ))"
check "активные сессии (моложе суток) на месте" fresh_present
check_http "GET /health → 200" 200 http://127.0.0.1:8003/health
check_http "POST /write → 201" 201 -X POST --data check http://127.0.0.1:8003/write
finish
