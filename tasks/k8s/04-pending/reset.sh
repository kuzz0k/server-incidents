#!/usr/bin/env bash
# k8s-04: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=k8s-04
. "$(dirname "$0")/../../../lib/common.sh"

kc delete namespace k04 --ignore-not-found --wait=true >/dev/null 2>&1
exit 0
