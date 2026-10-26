#!/usr/bin/env bash
set -uo pipefail
TASK_ID=docker-07
. "$(dirname "$0")/../../../lib/check.sh"

nets() { docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}' "$1" 2>/dev/null; }
same_user_net() {
  local n
  for n in $(nets api); do
    [[ $n == bridge || $n == host || $n == none ]] && continue
    nets web | tr ' ' '\n' | grep -qx "$n" && return 0
  done
  return 1
}
no_links() { [[ $(docker inspect -f '{{.HostConfig.Links}}' web) =~ ^(\[\]|<no value>)$ ]]; }

echo "  Запускаю /opt/trainer-docker/proxy/run.sh…"
bash /opt/trainer-docker/proxy/run.sh >/dev/null 2>&1
wait_until 20 http_ok http://127.0.0.1:8207/
check_body "curl :8207 → ответ от api" "hello from api" http://127.0.0.1:8207/
check "api и web в одной пользовательской сети" same_user_net
check "без --link" no_links
check "nginx.conf не изменён" sha256sum -c --quiet "$TASK_VAR/nginx.sha256"
finish
