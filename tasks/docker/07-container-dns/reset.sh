#!/usr/bin/env bash
# docker-07: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=docker-07
. "$(dirname "$0")/../../../lib/common.sh"

docker rm -f api web >/dev/null 2>&1
docker network rm trainer-net >/dev/null 2>&1
docker rmi -f trainer/api:1.0 >/dev/null 2>&1
rm -rf /opt/trainer-docker/proxy
rmdir_empty /opt/trainer-docker
exit 0
