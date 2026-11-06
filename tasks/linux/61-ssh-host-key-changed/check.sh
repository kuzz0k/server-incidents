#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-61
. "$(dirname "$0")/../../../lib/check.sh"

KH=/home/syncer/.ssh/known_hosts
since=$(date '+%Y-%m-%d %H:%M:%S')
sync_ok() { wait_until 15 bash -c "journalctl -u mirror-sync --since '$since' --no-pager -q -o cat | grep -qx 'sync ok'"; }
new_key() { ssh-keygen -F '[127.0.0.1]:2222' -f "$KH" 2>/dev/null | grep -qF "$(cat "$TASK_VAR/new-key")"; }
no_old_key() { ! grep -qF "$(cat "$TASK_VAR/old-key")" "$KH"; }
strict_on() {
  ! grep -rqsiE 'StrictHostKeyChecking\s*=?\s*no|UserKnownHostsFile\s*=?\s*/dev/null' \
      /home/syncer/.ssh/config /etc/ssh/ssh_config /etc/ssh/ssh_config.d/ "$TRAINER_LIB/mirror-sync.sh" /etc/systemd/system/mirror-sync.service*
}

check "mirror-sync снова пишет sync ok" sync_ok
check "в known_hosts новый ключ [127.0.0.1]:2222" new_key
check "старого ключа в known_hosts нет" no_old_key
check "проверка ключа хоста не отключена" strict_on
finish
