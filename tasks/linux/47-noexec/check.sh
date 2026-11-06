#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-47
. "$(dirname "$0")/../../../lib/check.sh"

MP=/srv/tools
runs_ok() {
  local before; before=$(grep -c 'cache rotated' /var/log/cache-rotate.log 2>/dev/null || echo 0)
  systemctl start cache-rotate || return 1
  [[ $(systemctl show -p Result --value cache-rotate) == success ]] || return 1
  (( $(grep -c 'cache rotated' /var/log/cache-rotate.log 2>/dev/null || echo 0) > before ))
}
noexec_mounted() { findmnt -n -o OPTIONS "$MP" | tr ',' '\n' | grep -qx noexec; }
noexec_fstab() { awk -v mp="$MP" '$1 !~ /^#/ && $2 == mp {print $4}' /etc/fstab | tr ',' '\n' | grep -qx noexec; }

check "systemctl start cache-rotate успешен, скрипт отработал" runs_ok
check "$MP смонтирован с noexec" noexec_mounted
check "в fstab для $MP стоит noexec" noexec_fstab
check "скрипт лежит в $MP" test -f "$MP/rotate-cache.sh"
finish
