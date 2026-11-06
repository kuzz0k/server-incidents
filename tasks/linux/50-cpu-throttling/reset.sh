#!/usr/bin/env bash
# linux-50: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-50
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit pricing-api
exit 0
