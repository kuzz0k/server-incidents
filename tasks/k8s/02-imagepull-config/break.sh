#!/usr/bin/env bash
set -euo pipefail
TASK_ID=k8s-02
. "$(dirname "$0")/../../../lib/common.sh"

k8s_namespace k02
kc apply -f - >/dev/null <<'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: frontend-secrets
  namespace: k02
stringData:
  api-key: trainer-key-7d1f9
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: k02
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: frontend
          image: nginx:1.27-alpinee
          ports:
            - containerPort: 80
          env:
            - name: API_KEY
              valueFrom:
                secretKeyRef:
                  name: frontend-secrets
                  key: api_key
          resources:
            requests:
              cpu: 20m
              memory: 16Mi
EOF
