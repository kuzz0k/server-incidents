#!/usr/bin/env bash
# linux-61: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-61
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit mirror-sync trainer-sshd
remove_user syncer gitmirror
remove_group syncer gitmirror
rm -rf /etc/ssh/trainer-2222 /root/trainer-notes/linux-61.txt "$TRAINER_LIB/mirror-sync.sh"
rmdir_empty /root/trainer-notes
exit 0
