#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-01
. "$(dirname "$0")/../../../lib/check.sh"

MP=/var/lib/reports

check "$MP смонтирован с отдельного диска" mountpoint -q "$MP"
check "на $MP занято меньше 70%" bash -c "(( \$(df --output=pcent $MP | tail -1 | tr -dc 0-9) < 70 ))"
check "data/*.db на месте и не изменены" bash -c "cd $MP/data && sha256sum -c --quiet $TASK_VAR/data.sha256"
check "сервис reports активен" systemctl is-active -q reports
check_http "GET /health → 200" 200 http://127.0.0.1:8001/health
check_http "POST /write → 201" 201 -X POST --data check http://127.0.0.1:8001/write
finish
