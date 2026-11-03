#!/usr/bin/env bash
# docker-01: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=docker-01
. "$(dirname "$0")/../../../lib/common.sh"

docker rm -f payments-api >/dev/null 2>&1
docker rmi -f trainer/payments:1.0 >/dev/null 2>&1
rm -rf /opt/trainer-docker/payments
rmdir_empty /opt/trainer-docker
exit 0
