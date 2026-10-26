#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-07
. "$(dirname "$0")/../../../lib/check.sh"

CFG=/etc/inventory/config.ini
DATA=/var/lib/inventory

runs_as_inventory() {
  local pid
  pid=$(systemctl show -p MainPID --value inventory)
  [[ $pid != 0 ]] && [[ $(ps -o user= -p "$pid") == inventory ]]
}
mode_lacks() { (( (8#$(stat -c %a "$1") & $2) == 0 )); }

check "inventory активен" systemctl is-active -q inventory
check "процесс работает от пользователя inventory" runs_as_inventory
check_http "GET /health → 200" 200 http://127.0.0.1:8007/health
check "конфиг читается пользователем inventory" sudo -u inventory test -r "$CFG"
check "конфиг не читается прочими (other)" mode_lacks "$CFG" 8#004
check "каталог данных не доступен на запись всем" mode_lacks "$DATA" 8#002
finish
