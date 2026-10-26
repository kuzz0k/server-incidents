#!/usr/bin/env bash
# Эталонное решение k8s-03 (для tests/selftest.sh)
set -euo pipefail
k3s kubectl -n k03 patch svc backend --type=json -p='[
 {"op":"replace","path":"/spec/selector","value":{"app":"backend-api"}},
 {"op":"replace","path":"/spec/ports/0/targetPort","value":80}]'
k3s kubectl -n k03 patch ingress backend --type=json -p='[
 {"op":"replace","path":"/spec/rules/0/http/paths/0/backend/service/port/number","value":80}]'
sleep 5
