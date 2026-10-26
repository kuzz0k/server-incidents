#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-15
. "$(dirname "$0")/../../../lib/check.sh"

not_enabled() { ! systemctl is-enabled -q legacy-gw 2>/dev/null; }

check "gateway активен" systemctl is-active -q gateway
check_body "на 8015 отвечает gateway" "gateway ok" http://127.0.0.1:8015/
check "legacy-gw остановлен" bash -c "! systemctl is-active -q legacy-gw"
check "legacy-gw не в автозагрузке" not_enabled
finish
