#!/usr/bin/env bash
set -uo pipefail
TASK_ID=k8s-04
. "$(dirname "$0")/../../../lib/check.sh"

sc_exists() { local sc; sc=$(kc -n k04 get pvc worker-data -o jsonpath='{.spec.storageClassName}'); [[ -n $sc ]] && kc get storageclass "$sc"; }
pvc_bound() { [[ $(kc -n k04 get pvc worker-data -o jsonpath='{.status.phase}') == Bound ]]; }
mounted() { [[ $(kc -n k04 get deploy worker -o jsonpath='{.spec.template.spec.volumes[0].persistentVolumeClaim.claimName}') == worker-data ]]; }
requests_ok() {
  local cpu mem
  cpu=$(kc -n k04 get deploy worker -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')
  mem=$(kc -n k04 get deploy worker -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}')
  python3 - "$cpu" "$mem" <<'EOF'
import re, sys
cpu, mem = sys.argv[1], sys.argv[2]
def millicores(v):
    return float(v[:-1]) if v.endswith("m") else float(v) * 1000
units = {"Ki": 2**10, "Mi": 2**20, "Gi": 2**30, "K": 10**3, "M": 10**6, "G": 10**9, "": 1}
def to_bytes(v):
    m = re.fullmatch(r"([0-9.]+)([KMG]i?)?", v)
    return float(m.group(1)) * units[m.group(2) or ""]
sys.exit(0 if cpu and mem and millicores(cpu) <= 500 and to_bytes(mem) <= 512 * 2**20 else 1)
EOF
}

check "rollout deployment/worker завершён" kc -n k04 rollout status deploy/worker --timeout=120s
check "deployment/worker Available" kc -n k04 wait --for=condition=Available deploy/worker --timeout=30s
check "storageClass PVC существует" sc_exists
check "pvc/worker-data Bound" pvc_bound
check "воркер использует pvc worker-data" mounted
check "requests: CPU ≤ 500m, память ≤ 512Mi" requests_ok
finish
