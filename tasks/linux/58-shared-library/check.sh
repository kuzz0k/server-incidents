#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-58
. "$(dirname "$0")/../../../lib/check.sh"

no_copies() { [[ -z $(find /lib /usr/lib /usr/local/lib -name 'libvnd*' 2>/dev/null) ]]; }

check "vendor-scanner активен и стабилен 5 с" service_stable vendor-scanner 5
check_http "GET :8058/health → 200" 200 http://127.0.0.1:8058/health
check "libvnd.so.1 есть в ldconfig -p" bash -c "ldconfig -p | grep -q 'libvnd.so.1 .*=> /opt/vendor/lib/'"
check "нет копий в системных каталогах" no_copies
finish
