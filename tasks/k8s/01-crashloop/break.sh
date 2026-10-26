#!/usr/bin/env bash
set -euo pipefail
TASK_ID=k8s-01
. "$(dirname "$0")/../../../lib/common.sh"

k8s_namespace k01
kc apply -f - >/dev/null <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: api-code
  namespace: k01
data:
  server.py: |
    from http.server import BaseHTTPRequestHandler, HTTPServer

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            code = 200 if self.path == "/health" else 404
            self.send_response(code)
            self.end_headers()
            self.wfile.write(b"ok\n" if code == 200 else b"not found\n")

    print("api listening on :8080", flush=True)
    HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: k01
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
        - name: api
          image: python:3.12-alpine
          command: ["python3", "-u", "/app/server.py"]
          ports:
            - containerPort: 8080
          volumeMounts:
            - name: code
              mountPath: /opt/app
          readinessProbe:
            httpGet:
              path: /health
              port: 8080
            periodSeconds: 3
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8080
            initialDelaySeconds: 3
            periodSeconds: 3
            failureThreshold: 2
          resources:
            requests:
              cpu: 50m
              memory: 32Mi
            limits:
              memory: 128Mi
      volumes:
        - name: code
          configMap:
            name: api-code
EOF
kc -n k01 get cm api-code -o jsonpath='{.data.server\.py}' | sha256sum > "$TASK_VAR/cm.sha256"
