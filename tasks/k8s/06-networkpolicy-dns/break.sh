#!/usr/bin/env bash
set -euo pipefail
TASK_ID=k8s-06
. "$(dirname "$0")/../../../lib/common.sh"

kc delete namespace k06-other --ignore-not-found --wait=true >/dev/null 2>&1 || true
k8s_namespace k06-db
k8s_namespace k06-app
kc apply -f - >/dev/null <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata: {name: db-page, namespace: k06-db}
data:
  index.html: "db ok\n"
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: backend-db, namespace: k06-db}
spec:
  replicas: 1
  selector: {matchLabels: {app: backend-db}}
  template:
    metadata: {labels: {app: backend-db}}
    spec:
      containers:
        - name: db
          image: nginx:1.27-alpine
          ports: [{containerPort: 80}]
          volumeMounts: [{name: page, mountPath: /usr/share/nginx/html}]
          resources: {requests: {cpu: 10m, memory: 16Mi}}
      volumes: [{name: page, configMap: {name: db-page}}]
---
apiVersion: v1
kind: Service
metadata: {name: backend-db, namespace: k06-db}
spec:
  selector: {app: backend-db}
  ports: [{port: 80, targetPort: 80}]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: default-deny-ingress, namespace: k06-db}
spec:
  podSelector: {}
  policyTypes: [Ingress]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: allow-shop-frontend, namespace: k06-db}
spec:
  podSelector: {matchLabels: {app: backend-db}}
  policyTypes: [Ingress]
  ingress:
    - from:
        - namespaceSelector: {matchLabels: {team: shop}}
          podSelector: {matchLabels: {role: frontend}}
      ports: [{port: 80, protocol: TCP}]
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: frontend, namespace: k06-app}
spec:
  replicas: 1
  selector: {matchLabels: {app: frontend}}
  template:
    metadata: {labels: {app: frontend}}
    spec:
      containers:
        - name: frontend
          image: busybox:1.36
          env: [{name: DB_URL, value: "http://backend-db/"}]
          command: ["sh", "-c", "while true; do wget -qO- -T 3 \"$DB_URL\" || echo fail; sleep 5; done"]
          resources: {requests: {cpu: 10m, memory: 8Mi}}
EOF
kc -n k06-db rollout status deploy/backend-db --timeout=120s >/dev/null
kc -n k06-app rollout status deploy/frontend --timeout=120s >/dev/null
kc -n k06-db get networkpolicy default-deny-ingress -o jsonpath='{.spec}' > "$TASK_VAR/deny.json"
