#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-19
. "$(dirname "$0")/../../../lib/check.sh"

cache_ok() {
  local v
  v=$(sed -n 's/^\s*CACHE_MB\s*=\s*\([0-9]*\)\s*$/\1/p' /etc/imagecache.conf | tail -1)
  [[ -n $v ]] && (( v >= 1 && v <= 48 ))
}

check "imagecache активен и стабилен 10 с" service_stable imagecache 10
check_http "GET /health → 200" 200 http://127.0.0.1:8019/health
check "MemoryMax по-прежнему 64M" bash -c "[[ \$(systemctl show -p MemoryMax --value imagecache) == 67108864 ]]"
check "CACHE_MB от 1 до 48" cache_ok
finish
