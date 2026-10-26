#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-18
. "$(dirname "$0")/../../../lib/check.sh"

nofile_ok() { local n; n=$(systemctl show -p LimitNOFILE --value chat-server); [[ $n == infinity ]] || (( n >= 4096 )); }

check "chat-server активен и стабилен 5 с" service_stable chat-server 5
check_http "GET /health → 200" 200 http://127.0.0.1:8018/health
check "LimitNOFILE ≥ 4096" nofile_ok
check "лимит задан через drop-in" bash -c "grep -qs '^LimitNOFILE=' /etc/systemd/system/chat-server.service.d/*.conf"
check "OPEN_FDS по-прежнему 300" bash -c "systemctl show -p Environment --value chat-server | grep -qw OPEN_FDS=300"
finish
