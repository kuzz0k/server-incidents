#!/usr/bin/env bash
# linux-59: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-59
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit cache-warmer search-indexer
rm -f "$TRAINER_LIB/cache-warmer.py"
exit 0
