#!/usr/bin/env bash
# k8s-05: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=k8s-05
. "$(dirname "$0")/../../../lib/common.sh"

helm uninstall hello -n k05 >/dev/null 2>&1
kc delete namespace k05 --ignore-not-found --wait=true >/dev/null 2>&1
rm -rf /opt/trainer-k8s/charts/hello
rmdir_empty /opt/trainer-k8s/charts /opt/trainer-k8s
exit 0
