#!/usr/bin/env bash
# linux-42: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-42
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit log-flood
rm -f /etc/systemd/journald.conf.d/90-retention.conf "$TRAINER_LIB/log-flood.py"
rmdir_empty /etc/systemd/journald.conf.d
systemctl restart systemd-journald
exit 0
