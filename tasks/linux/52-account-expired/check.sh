#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-52
. "$(dirname "$0")/../../../lib/check.sh"

port=$(sshd -T 2>/dev/null | awk '$1 == "port" {print $2; exit}')
login() {
  [[ $(ssh -i /root/trainer-keys/reporter_ed25519 -p "${port:-22}" -o BatchMode=yes -o ConnectTimeout=5 \
        -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null reporter@127.0.0.1 id -un 2>/dev/null) == reporter ]]
}
not_expired() {
  local e; e=$(getent shadow reporter | cut -d: -f8)
  [[ -z $e ]] || (( e > $(date +%s) / 86400 ))
}

check "reporter входит по ключу" login
check "срок действия учётки не истёк" not_expired
check "в authorized_keys тот же ключ" grep -qF "$(cat "$TASK_VAR/key")" /home/reporter/.ssh/authorized_keys
finish
