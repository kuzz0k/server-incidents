#!/usr/bin/env bash
# docker-03: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=docker-03
. "$(dirname "$0")/../../../lib/common.sh"

if [[ -f /opt/trainer-docker/notes/compose.yaml ]]; then
  (cd /opt/trainer-docker/notes && docker compose down -v --rmi local --remove-orphans >/dev/null 2>&1)
fi
docker rmi -f notes-web >/dev/null 2>&1
rm -rf /opt/trainer-docker/notes
rmdir_empty /opt/trainer-docker
exit 0
