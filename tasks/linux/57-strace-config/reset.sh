#!/usr/bin/env bash
# linux-57: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-57
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit geo-api
rm -rf /opt/geo-api /etc/geo /etc/geo-api.conf
exit 0
