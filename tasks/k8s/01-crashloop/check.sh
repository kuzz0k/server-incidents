#!/usr/bin/env bash
set -uo pipefail
TASK_ID=k8s-01
. "$(dirname "$0")/../../../lib/check.sh"

restarts() { kc -n k01 get pods -l app=api --field-selector=status.phase=Running -o jsonpath='{range .items[*]}{.status.containerStatuses[0].restartCount}{" "}{end}'; }
stable() {
  local a; a=$(restarts); [[ -n $a ]] || return 1
  sleep 20
  [[ $(restarts) == "$a" ]]
}
cm_same() { [[ $(kc -n k01 get cm api-code -o jsonpath='{.data.server\.py}' | sha256sum) == "$(cat "$TASK_VAR/cm.sha256")" ]]; }
probes() {
  local p; p=$(kc -n k01 get deploy api -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.path} {.spec.template.spec.containers[0].readinessProbe.httpGet.path}')
  [[ $(wc -w <<<"$p") -eq 2 ]]
}

check "rollout deployment/api завершён" kc -n k01 rollout status deploy/api --timeout=90s
check "deployment/api Available, под Ready" kc -n k01 wait --for=condition=Available deploy/api --timeout=30s
check "рестарты не растут 20 с" stable
check "ConfigMap api-code не изменён" cm_same
check "liveness и readiness на месте" probes
finish
