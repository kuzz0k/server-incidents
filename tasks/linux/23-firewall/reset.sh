#!/usr/bin/env bash
# linux-23: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-23
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit dashboard fw-hardening
iptables -D INPUT -j HARDENING 2>/dev/null
iptables -F HARDENING 2>/dev/null
iptables -X HARDENING 2>/dev/null
rm -f /usr/local/sbin/fw-hardening.sh
exit 0
