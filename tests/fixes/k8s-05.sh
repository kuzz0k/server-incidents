#!/usr/bin/env bash
# Эталонное решение k8s-05 (для tests/selftest.sh)
set -euo pipefail
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
cd /opt/trainer-k8s/charts/hello
sed -i 's/\.Values\.replicas }}/.Values.replicaCount }}/' templates/deployment.yaml
sed -i 's/\.Values\.image\.tag }}/.Values.image.version }}/' templates/deployment.yaml
sed -i 's|/usr/share/nginx/html/index.htm$|/usr/share/nginx/html/index.html|' templates/deployment.yaml
helm upgrade --install hello . -n k05 >/dev/null
k3s kubectl -n k05 rollout status deploy/hello --timeout=180s
