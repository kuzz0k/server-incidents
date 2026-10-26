#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-25
. "$(dirname "$0")/../../../lib/check.sh"

curl_backend() { ip netns exec tr-client curl -fs --max-time 3 http://10.26.0.2:8080/ | grep -q 'backend ok'; }
no_nat() { ! ip netns exec tr-router iptables-save -t nat 2>/dev/null | grep -Eq 'MASQUERADE|SNAT'; }

check "namespaces стенда на месте" bash -c "ip netns list | grep -q tr-client && ip netns list | grep -q tr-backend"
check "client → backend: curl 10.26.0.2:8080 → backend ok" curl_backend
check "адрес клиента 10.25.0.2/24" bash -c "ip -n tr-client -4 addr show dev c0 | grep -q 'inet 10.25.0.2/24'"
check "в tr-router нет NAT" no_nat
finish
