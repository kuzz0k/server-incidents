#!/usr/bin/env bash
# linux-10: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-10
. "$(dirname "$0")/../../../lib/common.sh"

remove_user dev1 dev2 dev3
remove_group devteam
rm -rf /srv/projects
exit 0
