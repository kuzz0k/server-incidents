#!/usr/bin/env bash
# docker-06: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=docker-06
. "$(dirname "$0")/../../../lib/common.sh"

docker rm -f worker >/dev/null 2>&1
docker rmi -f trainer/worker:1.0 >/dev/null 2>&1
rm -rf /opt/trainer-docker/worker
rmdir_empty /opt/trainer-docker
exit 0
