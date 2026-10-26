#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-09
. "$(dirname "$0")/../../../lib/check.sh"

port=$(sshd -T 2>/dev/null | awk '$1 == "port" {print $2; exit}')
alice_login() {
  [[ $(ssh -i /root/trainer-keys/alice_ed25519 -p "${port:-22}" -o BatchMode=yes -o ConnectTimeout=5 \
        -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null alice@127.0.0.1 id -un 2>/dev/null) == alice ]]
}

check "alice входит по ключу и получает shell" alice_login
check "home alice без записи для group/other" bash -c "(( (8#\$(stat -c %a /home/alice) & 8#022) == 0 ))"
finish
