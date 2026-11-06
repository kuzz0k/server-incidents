#!/usr/bin/env bash
# linux-58: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-58
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit vendor-scanner
grep -lsF /opt/vendor/lib /etc/ld.so.conf.d/*.conf | xargs -r rm -f
grep -qsF /opt/vendor/lib /etc/ld.so.conf && sed -i '\|/opt/vendor/lib|d' /etc/ld.so.conf
find /lib /usr/lib /usr/local/lib -name 'libvnd*' -delete 2>/dev/null
rm -rf /opt/vendor
ldconfig
exit 0
