#!/usr/bin/env bash
set -euo pipefail
TASK_ID=k8s-05
. "$(dirname "$0")/../../../lib/common.sh"

C=/opt/trainer-k8s/charts/hello
helm uninstall hello -n k05 >/dev/null 2>&1 || true
k8s_namespace k05
rm -rf "$C"
mkdir -p "$C/templates"
cat > "$C/Chart.yaml" <<'EOF'
apiVersion: v2
name: hello
description: Hello page served by nginx
version: 0.1.0
appVersion: "1.27"
EOF
cat > "$C/values.yaml" <<'EOF'
replicaCount: 3
image:
  repository: nginx
  version: 1.27-alpine
message: "hello from helm"
service:
  port: 80
EOF
cat > "$C/templates/configmap.yaml" <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-html
data:
  index.html: {{ .Values.message | quote }}
EOF
cat > "$C/templates/deployment.yaml" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
  labels:
    app: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicas }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
    spec:
      containers:
        - name: web
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: 80
          volumeMounts:
            - name: html
              mountPath: /usr/share/nginx/html/index.htm
              subPath: index.html
          resources:
            requests:
              cpu: 10m
              memory: 16Mi
      volumes:
        - name: html
          configMap:
            name: {{ .Release.Name }}-html
EOF
cat > "$C/templates/service.yaml" <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}
spec:
  selector:
    app: {{ .Release.Name }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: 80
EOF
helm upgrade --install hello "$C" -n k05 >/dev/null
