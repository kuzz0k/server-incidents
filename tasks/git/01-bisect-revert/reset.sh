#!/usr/bin/env bash
# git-01: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=git-01
. "$(dirname "$0")/../../../lib/common.sh"

rm -rf /srv/git/billing
rmdir_empty /srv/git
exit 0
