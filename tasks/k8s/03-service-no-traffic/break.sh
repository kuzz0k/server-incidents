#!/usr/bin/env bash
set -euo pipefail
TASK_ID=k8s-03
. "$(dirname "$0")/../../../lib/common.sh"

info "Жду traefik в kube-system…"
wait_until 180 kc -n kube-system get deploy traefik || die "traefik не появился в kube-system (k3s поставлен без него?)"
kc -n kube-system rollout status deploy/traefik --timeout=180s >/dev/null

k8s_namespace k03
kc apply -f - >/dev/null <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-html
  namespace: k03
data:
  index.html: "backend ok\n"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: k03
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend-api
  template:
    metadata:
      labels:
        app: backend-api
    spec:
      containers:
        - name: nginx
          image: nginx:1.27-alpine
          ports:
            - containerPort: 80
          volumeMounts:
            - name: html
              mountPath: /usr/share/nginx/html
          resources:
            requests:
              cpu: 20m
              memory: 16Mi
      volumes:
        - name: html
          configMap:
            name: backend-html
---
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: k03
spec:
  selector:
    app: backend
  ports:
    - port: 80
      targetPort: 8080
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: backend
  namespace: k03
spec:
  ingressClassName: traefik
  rules:
    - host: backend.trainer.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: backend
                port:
                  number: 8080
EOF
kc -n k03 rollout status deploy/backend --timeout=120s >/dev/null
