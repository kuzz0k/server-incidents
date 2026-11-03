#!/usr/bin/env bash
# docker-02: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=docker-02
. "$(dirname "$0")/../../../lib/common.sh"

docker rm -f catalog >/dev/null 2>&1
docker rmi -f trainer/catalog:1.0 >/dev/null 2>&1
rm -rf /opt/trainer-docker/catalog
rmdir_empty /opt/trainer-docker
exit 0
