#!/usr/bin/env bash
# linux-21: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-21
. "$(dirname "$0")/../../../lib/common.sh"

rm -f /etc/systemd/resolved.conf.d/90-corp-dns.conf
rmdir_empty /etc/systemd/resolved.conf.d
restore_original /etc/resolv.conf
systemctl restart systemd-resolved 2>/dev/null
resolvectl flush-caches 2>/dev/null
exit 0
