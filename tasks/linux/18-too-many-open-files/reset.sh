#!/usr/bin/env bash
# linux-18: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-18
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit chat-server
remove_user chat
rm -f /etc/security/limits.d/90-chat.conf
exit 0
