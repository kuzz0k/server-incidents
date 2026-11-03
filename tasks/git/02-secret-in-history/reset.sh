#!/usr/bin/env bash
# git-02: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=git-02
. "$(dirname "$0")/../../../lib/common.sh"

rm -rf /srv/git/shop /srv/git/shop-remote.git
rmdir_empty /srv/git
exit 0
