#!/usr/bin/env bash
set -uo pipefail
TASK_ID=docker-01
. "$(dirname "$0")/../../../lib/check.sh"

C=payments-api
insp() { docker inspect -f "$1" "$C" 2>/dev/null; }
stable() {
  local r1
  [[ $(insp '{{.State.Running}}') == true ]] || return 1
  r1=$(insp '{{.RestartCount}}'); sleep 5
  [[ $(insp '{{.State.Running}}') == true && $(insp '{{.RestartCount}}') == "$r1" ]]
}
policy_ok() { [[ $(insp '{{.HostConfig.RestartPolicy.Name}}') =~ ^(unless-stopped|always)$ ]]; }

echo "  Запускаю /opt/trainer-docker/payments/run.sh…"
bash /opt/trainer-docker/payments/run.sh >/dev/null 2>&1
sleep 3
check "контейнер $C работает 5 с без рестартов" stable
check "restart policy unless-stopped/always" policy_ok
check "образ trainer/payments:1.0" bash -c "[[ \$(docker inspect -f '{{.Config.Image}}' $C) == trainer/payments:1.0 ]]"
check_http "GET :8201/health → 200" 200 http://127.0.0.1:8201/health
finish
