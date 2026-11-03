#!/usr/bin/env bash
# linux-35: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-35
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit healthcheck.timer healthcheck.service health-check.service
rm -f /usr/local/bin/healthcheck.sh /var/log/healthcheck.log
exit 0
