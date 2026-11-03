#!/usr/bin/env bash
# k8s-02: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=k8s-02
. "$(dirname "$0")/../../../lib/common.sh"

kc delete namespace k02 --ignore-not-found --wait=true >/dev/null 2>&1
exit 0
