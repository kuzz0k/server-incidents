#!/usr/bin/env bash
# Эталонное решение k8s-04 (для tests/selftest.sh)
set -euo pipefail
kc() { k3s kubectl "$@"; }
kc -n k04 scale deploy worker --replicas=0
kc -n k04 delete pvc worker-data --wait=true
kc -n k04 apply -f - <<'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: worker-data, namespace: k04}
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: local-path
  resources: {requests: {storage: 1Gi}}
EOF
kc -n k04 set resources deploy worker --requests=cpu=100m,memory=128Mi --limits=memory=256Mi
kc -n k04 scale deploy worker --replicas=1
kc -n k04 rollout status deploy/worker --timeout=180s
