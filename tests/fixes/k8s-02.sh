#!/usr/bin/env bash
# Эталонное решение k8s-02 (для tests/selftest.sh)
set -euo pipefail
k3s kubectl -n k02 patch deploy frontend --type=json -p='[
 {"op":"replace","path":"/spec/template/spec/containers/0/image","value":"nginx:1.27-alpine"},
 {"op":"replace","path":"/spec/template/spec/containers/0/env/0/valueFrom/secretKeyRef/key","value":"api-key"}]'
k3s kubectl -n k02 rollout status deploy/frontend --timeout=180s
