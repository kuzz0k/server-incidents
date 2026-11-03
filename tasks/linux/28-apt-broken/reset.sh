#!/usr/bin/env bash
# linux-28: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-28
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit apt-autoupdate
rm -f /etc/apt/sources.list.d/vendor-tools.list "$TRAINER_LIB/apt-autoupdate.py"
for p in jq tree; do
  [[ $(recall "$p-installed") == no ]] && pkg_installed "$p" && apt-get purge -y -qq "$p" >/dev/null 2>&1
done
exit 0
