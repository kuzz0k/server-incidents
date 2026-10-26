#!/usr/bin/env bash
set -uo pipefail
TASK_ID=docker-02
. "$(dirname "$0")/../../../lib/check.sh"

echo "  Запускаю /opt/trainer-docker/catalog/run.sh…"
bash /opt/trainer-docker/catalog/run.sh >/dev/null 2>&1
wait_until 10 http_ok http://127.0.0.1:8202/health
check "контейнер catalog работает" bash -c "[[ \$(docker inspect -f '{{.State.Running}}' catalog) == true ]]"
check_http "GET :8202/health → 200" 200 http://127.0.0.1:8202/health
check "сеть контейнера не host" bash -c "[[ \$(docker inspect -f '{{.HostConfig.NetworkMode}}' catalog) != host ]]"
check "образ trainer/catalog:1.0" bash -c "[[ \$(docker inspect -f '{{.Config.Image}}' catalog) == trainer/catalog:1.0 ]]"
finish
