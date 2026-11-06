#!/usr/bin/env bash
# linux-52: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-52
. "$(dirname "$0")/../../../lib/common.sh"

remove_user reporter
remove_group reporter
rm -f /root/trainer-keys/reporter_ed25519 /root/trainer-keys/reporter_ed25519.pub
rmdir_empty /root/trainer-keys
exit 0
