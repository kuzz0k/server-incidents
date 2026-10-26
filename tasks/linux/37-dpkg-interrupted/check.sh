#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-37
. "$(dirname "$0")/../../../lib/check.sh"

check "checkout-agent: install ok installed" pkg_installed checkout-agent
check "dpkg --audit ничего не находит" bash -c "[[ -z \$(dpkg --audit 2>&1) ]]"
check "сервис checkout-agent активен" systemctl is-active -q checkout-agent
check_http "GET :8037/health → 200" 200 http://127.0.0.1:8037/health
finish
