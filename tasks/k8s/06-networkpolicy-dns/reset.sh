#!/usr/bin/env bash
# k8s-06: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=k8s-06
. "$(dirname "$0")/../../../lib/common.sh"

for ns in k06-app k06-db k06-other; do
  kc delete namespace "$ns" --ignore-not-found --wait=true >/dev/null 2>&1
done
exit 0
