#!/usr/bin/env bash
set -uo pipefail
TASK_ID=k8s-06
. "$(dirname "$0")/../../../lib/check.sh"

frontend_ok() {
  kc -n k06-app rollout status deploy/frontend --timeout=60s >/dev/null || return 1
  kc -n k06-app exec deploy/frontend -- sh -c 'wget -qO- -T 5 "$DB_URL"' 2>/dev/null | grep -q 'db ok'
}
deny_kept() { [[ $(kc -n k06-db get networkpolicy default-deny-ingress -o jsonpath='{.spec}' 2>/dev/null) == "$(cat "$TASK_VAR/deny.json")" ]]; }
intruder_blocked() {
  kc create namespace k06-other >/dev/null 2>&1
  kc -n k06-other run intruder --image=busybox:1.36 --labels=role=frontend --restart=Never \
    --command -- sleep 600 >/dev/null 2>&1
  kc -n k06-other wait --for=condition=Ready pod/intruder --timeout=90s >/dev/null || return 1
  ! kc -n k06-other exec intruder -- wget -qO- -T 5 http://backend-db.k06-db.svc.cluster.local/ >/dev/null 2>&1
}

check "фронтенд получает db ok" frontend_ok
check "default-deny-ingress на месте и не изменён" deny_kept
check "под из чужого namespace заблокирован" intruder_blocked
kc delete namespace k06-other --wait=false >/dev/null 2>&1
finish
