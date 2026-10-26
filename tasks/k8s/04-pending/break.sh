#!/usr/bin/env bash
set -euo pipefail
TASK_ID=k8s-04
. "$(dirname "$0")/../../../lib/common.sh"

k8s_namespace k04
kc apply -f - >/dev/null <<'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: worker-data
  namespace: k04
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: fast-ssd
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: worker
  namespace: k04
spec:
  replicas: 1
  selector:
    matchLabels:
      app: worker
  template:
    metadata:
      labels:
        app: worker
    spec:
      containers:
        - name: worker
          image: busybox:1.36
          command: ["sh", "-c", "echo started >> /data/worker.log; while true; do sleep 30; done"]
          volumeMounts:
            - name: data
              mountPath: /data
          resources:
            requests:
              cpu: "8"
              memory: 16Gi
            limits:
              memory: 16Gi
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: worker-data
EOF
