#!/usr/bin/env bash
# linux-53: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-53
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit report-exporter reports-web
remove_user exporter www-reports
remove_group reports exporter www-reports
rm -rf /srv/reports "$TRAINER_LIB/report-exporter.py" "$TRAINER_LIB/reports-web.py"
exit 0
