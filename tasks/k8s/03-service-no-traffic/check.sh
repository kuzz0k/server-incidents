#!/usr/bin/env bash
set -uo pipefail
TASK_ID=k8s-03
. "$(dirname "$0")/../../../lib/check.sh"

IP=$(primary_ip)
has_endpoints() { [[ -n $(kc -n k03 get endpointslices -l kubernetes.io/service-name=backend -o jsonpath='{.items[*].endpoints[*].addresses[*]}') ]]; }
via_ingress() { curl -fsS --max-time 5 -H 'Host: backend.trainer.local' "http://$IP/" | grep -q 'backend ok'; }

check "у service/backend есть endpoints" has_endpoints
check "curl через Ingress → backend ok" wait_until 15 via_ingress
check "образ подов не менялся" bash -c "[[ \$(k3s kubectl -n k03 get deploy backend -o jsonpath='{.spec.template.spec.containers[0].image}') == nginx:1.27-alpine ]]"
finish
