#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-22
. "$(dirname "$0")/../../../lib/check.sh"

resolves_to_new() { [[ $(getent ahostsv4 api.payments.internal | awk '{print $1}' | sort -u | tr '\n' ' ') == "127.0.0.22 " ]]; }

check "api.payments.internal резолвится только в новый адрес" resolves_to_new
check_body "curl http://api.payments.internal:8022/ → payments-api ok" "payments-api ok" http://api.payments.internal:8022/
check "payments-api слушает свой адрес 127.0.0.22" bash -c "ss -Hltn 'sport = :8022' | grep -q '127.0.0.22:8022'"
finish
