#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-28
. "$(dirname "$0")/../../../lib/check.sh"

update_clean() {
  local out
  out=$(timeout 180 apt-get update 2>&1) || return 1
  ! grep -q '^E:' <<<"$out"
}
lock_free() { ! fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; }
agent_off() { ! systemctl is-active -q apt-autoupdate && ! systemctl is-enabled -q apt-autoupdate 2>/dev/null; }

check "агент автообновлений остановлен и выключен" agent_off
check "блокировку dpkg никто не держит" lock_free
check "apt-get update без ошибок" update_clean
check "jq установлен" pkg_installed jq
check "tree установлен" pkg_installed tree
finish
