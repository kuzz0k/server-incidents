#!/usr/bin/env bash
set -uo pipefail
TASK_ID=k8s-02
. "$(dirname "$0")/../../../lib/check.sh"

all_ready() {
  local ready want
  ready=$(kc -n k02 get deploy frontend -o jsonpath='{.status.readyReplicas}')
  want=$(kc -n k02 get deploy frontend -o jsonpath='{.spec.replicas}')
  [[ -n $ready && $ready == "$want" ]]
}
key_ok() {
  local want got
  want=$(kc -n k02 get secret frontend-secrets -o jsonpath='{.data.api-key}' | base64 -d)
  got=$(kc -n k02 exec deploy/frontend -- printenv API_KEY 2>/dev/null)
  [[ -n $want && $got == "$want" ]]
}

check "rollout deployment/frontend завершён" kc -n k02 rollout status deploy/frontend --timeout=120s
check "все реплики Ready" all_ready
check "API_KEY совпадает с секретом" key_ok
check "значение в секрете не изменено" bash -c "[[ \$(k3s kubectl -n k02 get secret frontend-secrets -o jsonpath='{.data.api-key}' | base64 -d) == trainer-key-7d1f9 ]]"
finish
