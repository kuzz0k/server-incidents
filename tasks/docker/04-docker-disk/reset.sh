#!/usr/bin/env bash
# docker-04: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=docker-04
. "$(dirname "$0")/../../../lib/common.sh"

docker rm -f chatty >/dev/null 2>&1
docker ps -aq --filter 'name=^junk-' | xargs -r docker rm -f >/dev/null
docker rmi trainer/keep:prod trainer/junk:latest >/dev/null 2>&1
docker image prune -f --filter label=devops-trainer=docker-04 >/dev/null 2>&1
rm -rf /opt/trainer-docker/chatty
rmdir_empty /opt/trainer-docker
before=$(sha256sum /etc/docker/daemon.json 2>/dev/null)
restore_original /etc/docker/daemon.json
[[ $(sha256sum /etc/docker/daemon.json 2>/dev/null) != "$before" ]] && systemctl restart docker
exit 0
