#!/usr/bin/env bash
# linux-06: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-06
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit billing-app
remove_user billing
rm -rf /var/log/billing /etc/logrotate.d/billing
exit 0
