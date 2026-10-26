#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-21
. "$(dirname "$0")/../../../lib/check.sh"

resolv_is_link() { [[ -L /etc/resolv.conf ]] && readlink -f /etc/resolv.conf | grep -q '^/run/systemd/resolve/'; }

check "getent hosts archive.ubuntu.com" timeout 15 getent hosts archive.ubuntu.com
check "/etc/resolv.conf — симлинк на systemd-resolved" resolv_is_link
check "в /etc/resolv.conf нет 192.0.2.53" bash -c "! grep -q 192.0.2.53 /etc/resolv.conf"
check "в resolvectl status нет 192.0.2.53" bash -c "! resolvectl status | grep -q 192.0.2.53"
finish
