#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-56
. "$(dirname "$0")/../../../lib/check.sh"

persisted() {
  local v
  v=$(grep -rhsE '^\s*fs\.inotify\.max_user_watches\s*=' /etc/sysctl.conf /etc/sysctl.d/ | tail -1 | sed 's/.*=\s*//')
  [[ $v =~ ^[0-9]+$ ]] && (( v >= 10000 ))
}

check "file-sync активен и стабилен 5 с" service_stable file-sync 5
check "fs.inotify.max_user_watches ≥ 10000 сейчас" bash -c "(( \$(sysctl -n fs.inotify.max_user_watches) >= 10000 ))"
check "лимит сохранён в sysctl-конфиге" persisted
check "каталоги на месте" bash -c "[[ \$(find /srv/sync-data -type d | wc -l) -ge $(cat "$TASK_VAR/dirs") ]]"
finish
