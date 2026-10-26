#!/usr/bin/env bash
set -uo pipefail
TASK_ID=docker-03
. "$(dirname "$0")/../../../lib/check.sh"

APP=/opt/trainer-docker/notes
marker="note-$(date +%s)-$RANDOM"
dc() { (cd "$APP" && docker compose "$@"); }
cycle() { dc down >/dev/null 2>&1 && (cd "$APP" && timeout 200 docker compose up -d --build --wait) >/dev/null 2>&1; }
web_ok() { wait_until 20 http_ok http://127.0.0.1:8203/health; }
add_note() { [[ $(http_code -X POST --data "$marker" http://127.0.0.1:8203/notes) == 201 ]]; }
note_present() { web_ok && curl -fsS --max-time 5 http://127.0.0.1:8203/notes | grep -qF "$marker"; }

echo "  Пересоздаю стек (down → up --wait), это займёт до пары минут…"
check "стек поднимается: down → up -d --wait" cycle
check "web отвечает на /health" web_ok
check "заметка добавляется" add_note
check "стек снова поднимается после down" cycle
check "заметка пережила пересоздание контейнеров" note_present
finish
