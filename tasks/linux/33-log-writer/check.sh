#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-33
. "$(dirname "$0")/../../../lib/check.sh"

LOG=/var/log/trainer/bad.log
not_shrunk() { [[ -f $LOG ]] && (( $(stat -c %s "$LOG") >= $(cat "$TASK_VAR/size") )); }
not_growing() { local a; a=$(stat -c %s "$LOG") || return 1; sleep 5; [[ $(stat -c %s "$LOG") == "$a" ]]; }
not_open() { ! fuser "$LOG" >/dev/null 2>&1; }
unit_off() { ! systemctl is-active -q report-sync && ! systemctl is-enabled -q report-sync 2>/dev/null; }

check "bad.log на месте и не стал меньше" not_shrunk
check "bad.log не растёт 5 секунд" not_growing
check "файл не держит открытым ни один процесс" not_open
check "виновный сервис остановлен и выключен" unit_off
finish
