#!/usr/bin/env bash
# linux-60: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-60
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit media-api
rm -rf /srv/media-store
remove_user media
remove_group media
exit 0
