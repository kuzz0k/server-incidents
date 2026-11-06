#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-54
. "$(dirname "$0")/../../../lib/check.sh"

runs_as_user() { local pid; pid=$(systemctl show -p MainPID --value ldap-proxy); [[ $pid != 0 && $(ps -o user= -p "$pid") == ldapproxy ]]; }
no_py_caps() { ! getcap "$(readlink -f /usr/bin/python3)" 2>/dev/null | grep -q cap_; }

check "ldap-proxy активен" systemctl is-active -q ldap-proxy
check "процесс работает от ldapproxy" runs_as_user
check_body "на 389 отвечает ldap-proxy" "ldap-proxy ok" http://127.0.0.1:389/
check "ip_unprivileged_port_start не изменён" bash -c "[[ \$(sysctl -n net.ipv4.ip_unprivileged_port_start) == $(recall unpriv-port) ]]"
check "у python3 нет file capabilities" no_py_caps
finish
