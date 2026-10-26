#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-38
. "$(dirname "$0")/../../../lib/check.sh"

IP=$(primary_ip)
check_body "curl 127.0.0.1:8038 → legacy billing" "legacy billing" http://127.0.0.1:8038/
check_body "curl $IP:8038 → legacy billing" "legacy billing" "http://$IP:8038/"
check "приложение слушает 20280" port_listening 20280
check "юнит legacy-billing не изменён" bash -c "[[ \$(systemctl cat legacy-billing | sha256sum) == \"\$(cat $TASK_VAR/unit.sha256)\" ]]"
finish
