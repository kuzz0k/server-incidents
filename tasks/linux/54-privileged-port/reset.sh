#!/usr/bin/env bash
# linux-54: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-54
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit ldap-proxy
remove_user ldapproxy
remove_group ldapproxy
v=$(recall unpriv-port); [[ -n $v ]] && sysctl -qw net.ipv4.ip_unprivileged_port_start="$v"
setcap -r "$(readlink -f /usr/bin/python3)" 2>/dev/null
exit 0
