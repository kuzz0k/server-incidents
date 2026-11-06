#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-60
. "$(dirname "$0")/../../../lib/check.sh"

check "media-api активен" systemctl is-active -q media-api
check_http "GET :8060/health → 200" 200 http://127.0.0.1:8060/health
check "нет файлов без владельца/группы" bash -c "[[ -z \$(find /srv/media-store \( -nouser -o -nogroup \) -print -quit) ]]"
check "UID media не изменился" bash -c "[[ \$(id -u media) == \$(cat $TASK_VAR/uid) ]]"
check "ничего не доступно на запись всем" bash -c "[[ -z \$(find /srv/media-store -perm -o+w -print -quit) ]]"
finish
