#!/usr/bin/env bash
# Эталонное решение k8s-06 (для tests/selftest.sh)
set -euo pipefail
kc() { k3s kubectl "$@"; }
kc label namespace k06-app team=shop --overwrite
kc -n k06-app patch deploy frontend --type=merge -p '{"spec":{"template":{"metadata":{"labels":{"role":"frontend"}}}}}'
kc -n k06-app set env deploy/frontend DB_URL=http://backend-db.k06-db.svc.cluster.local/
kc -n k06-app rollout status deploy/frontend --timeout=120s
