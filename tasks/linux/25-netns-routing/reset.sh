#!/usr/bin/env bash
# linux-25: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-25
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit tr-netns-backend
for ns in tr-client tr-router tr-backend; do ip netns del "$ns" 2>/dev/null; done
rm -rf /opt/netns-lab
exit 0
