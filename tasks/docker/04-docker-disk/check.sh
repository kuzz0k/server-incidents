#!/usr/bin/env bash
set -uo pipefail
TASK_ID=docker-04
. "$(dirname "$0")/../../../lib/check.sh"

no_dangling() { [[ -z $(docker images -q -f dangling=true) ]]; }
no_junk() { [[ -z $(docker ps -aq --filter 'name=^junk-') ]]; }
daemon_max_size() { python3 -c 'import json; c = json.load(open("/etc/docker/daemon.json")); assert c["log-opts"]["max-size"]'; }
chatty_running() { [[ $(docker inspect -f '{{.State.Running}}' chatty 2>/dev/null) == true ]]; }
chatty_limited() { docker inspect -f '{{json .HostConfig.LogConfig.Config}}' chatty | grep -q max-size; }
chatty_small() {
  local log; log=$(docker inspect -f '{{.LogPath}}' chatty) || return 1
  (( $(stat -c %s "$log") < 60 * 1024 * 1024 ))
}

check "нет dangling-образов" no_dangling
check "нет контейнеров junk-*" no_junk
check "образ trainer/keep:prod на месте" docker image inspect trainer/keep:prod
check "в daemon.json задан log-opts.max-size" daemon_max_size
check "chatty работает" chatty_running
check "у chatty действует max-size" chatty_limited
check "лог chatty меньше 60 МБ" chatty_small
finish
