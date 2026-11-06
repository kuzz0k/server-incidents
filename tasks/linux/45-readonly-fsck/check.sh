#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-45
. "$(dirname "$0")/../../../lib/check.sh"

MP=/srv/uploads
dev=$(disk_dev linux45)
same_disk() { [[ -n $dev && $(findmnt -n -o SOURCE "$MP") == "$dev" && $(disk_uuid "$dev") == "$(cat "$TASK_VAR/uuid")" ]]; }
rw() { findmnt -n -o OPTIONS "$MP" | tr ',' '\n' | grep -qx rw; }
no_errors() { ! dumpe2fs -h "$dev" 2>/dev/null | grep -i '^Filesystem state:' | grep -qi error; }

check "$MP смонтирован с того же диска (не переформатирован)" same_disk
check "$MP смонтирован в rw" rw
check "в суперблоке нет отметки об ошибках" no_errors
check "уцелевшие data/*.dat не изменились" bash -c "cd $MP/data && sha256sum -c --quiet $TASK_VAR/data.sha256"
check "uploads-api активен" systemctl is-active -q uploads-api
check_http "GET :8045/health → 200" 200 http://127.0.0.1:8045/health
finish
