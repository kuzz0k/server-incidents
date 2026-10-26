#!/usr/bin/env bash
# Эталонное решение k8s-01 (для tests/selftest.sh)
set -euo pipefail
k3s kubectl -n k01 patch deploy api --type=json -p='[
 {"op":"replace","path":"/spec/template/spec/containers/0/volumeMounts/0/mountPath","value":"/app"},
 {"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/path","value":"/health"}]'
k3s kubectl -n k01 rollout status deploy/api --timeout=120s
