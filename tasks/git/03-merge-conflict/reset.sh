#!/usr/bin/env bash
# git-03: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=git-03
. "$(dirname "$0")/../../../lib/common.sh"

rm -rf /srv/git/webapp
rmdir_empty /srv/git
exit 0
