#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-14
. "$(dirname "$0")/../../../lib/check.sh"

check "notifier активен" systemctl is-active -q notifier
check_http "GET /health → 200" 200 http://127.0.0.1:8014/health
check "multi-user.target хочет notifier" bash -c "systemctl show -p WantedBy --value notifier | grep -qw multi-user.target"
check "is-enabled = enabled" bash -c "[[ \$(systemctl is-enabled notifier) == enabled ]]"
finish
