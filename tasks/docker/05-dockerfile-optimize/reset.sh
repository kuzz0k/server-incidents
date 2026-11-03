#!/usr/bin/env bash
# docker-05: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=docker-05
. "$(dirname "$0")/../../../lib/common.sh"

docker rm -f reports-api-check >/dev/null 2>&1
docker rmi -f trainer/reports-api:2.0 >/dev/null 2>&1
rm -rf /opt/trainer-docker/reports-api
rmdir_empty /opt/trainer-docker
exit 0
