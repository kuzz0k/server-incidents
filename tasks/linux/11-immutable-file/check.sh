#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-11
. "$(dirname "$0")/../../../lib/check.sh"

has_attr() { lsattr -d "$1" 2>/dev/null | awk '{print $1}' | grep -q "$2"; }

check "в конфиге timeout: 30" grep -qx 'timeout: 30' /etc/payment/config.yml
check "конфиг снова immutable (+i)" has_attr /etc/payment/config.yml i
check "audit.log остался append-only (+a)" has_attr /var/log/payment/audit.log a
check "в audit.log есть запись о деплое timeout=30" grep -q 'deploy timeout=30' /var/log/payment/audit.log
check "старая запись в audit.log на месте" grep -q '2026-09-14T10:02:11' /var/log/payment/audit.log
finish
