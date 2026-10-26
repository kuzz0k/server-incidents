#!/usr/bin/env bash
set -uo pipefail
TASK_ID=nginx-04
. "$(dirname "$0")/../../../lib/check.sh"

f2=$(mktemp); f11=$(mktemp)
head -c 2M /dev/zero > "$f2"; head -c 11M /dev/zero > "$f11"
since=$(date '+%Y-%m-%d %H:%M:%S')

check_http "GET /api/v1/users → 200" 200 http://127.0.0.1:8104/api/v1/users
check_http "POST /api/upload 2 МБ → 200" 200 -X POST --data-binary "@$f2" http://127.0.0.1:8104/api/upload
check_http "POST /api/upload 11 МБ → 413" 413 -X POST --data-binary "@$f11" http://127.0.0.1:8104/api/upload
check "бэкенд не получал запросов с префиксом /api" bash -c "! journalctl -u api-backend --since '$since' --no-pager -q | grep -q 'GET /api/'"
rm -f "$f2" "$f11"
finish
