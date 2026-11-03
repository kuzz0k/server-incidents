#!/usr/bin/env bash
# linux-24: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-24
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit metrics-api
rm -f /etc/metrics-api.conf
exit 0
