#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-55
. "$(dirname "$0")/../../../lib/check.sh"

echo "  Имитирую перезагрузку: stop → rm -rf /run/sessiond → systemd-tmpfiles --create → start"
systemctl stop sessiond
rm -rf /run/sessiond
systemd-tmpfiles --create >/dev/null 2>&1
systemctl start sessiond
wait_for_port 8055

dir_ok() { [[ $(stat -c %U /run/sessiond 2>/dev/null) == sessiond ]] && (( (8#$(stat -c %a /run/sessiond) & 8#002) == 0 )); }
check_http "после «ребута» /health → 200" 200 http://127.0.0.1:8055/health
check "/run/sessiond принадлежит sessiond, не доступен на запись всем" dir_ok
finish
