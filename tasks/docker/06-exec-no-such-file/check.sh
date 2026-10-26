#!/usr/bin/env bash
set -uo pipefail
TASK_ID=docker-06
. "$(dirname "$0")/../../../lib/check.sh"

running_5s() {
  [[ $(docker inspect -f '{{.State.Running}}' worker 2>/dev/null) == true ]] || return 1
  local r; r=$(docker inspect -f '{{.RestartCount}}' worker); sleep 5
  [[ $(docker inspect -f '{{.State.Running}}' worker) == true && $(docker inspect -f '{{.RestartCount}}' worker) == "$r" ]]
}

echo "  Запускаю /opt/trainer-docker/worker/run.sh…"
check "run.sh отрабатывает" /opt/trainer-docker/worker/run.sh
sleep 2
check "контейнер worker работает 5 с без рестартов" running_5s
check "в логах worker started" bash -c "docker logs worker 2>&1 | grep -q 'worker started'"
check "образ на alpine" docker run --rm --entrypoint test trainer/worker:1.0 -f /etc/alpine-release
check "bash в образе нет" bash -c "! docker run --rm --entrypoint sh trainer/worker:1.0 -c 'command -v bash'"
finish
