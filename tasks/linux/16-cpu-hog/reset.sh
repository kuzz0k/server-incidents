#!/usr/bin/env bash
# linux-16: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-16
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit thumbnailer
remove_user thumbnailer
rm -rf /etc/thumbnailer.conf /var/spool/thumbnailer "$TRAINER_LIB/thumbnailer.py"
exit 0
