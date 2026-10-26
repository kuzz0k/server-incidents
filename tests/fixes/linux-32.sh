#!/usr/bin/env bash
# Эталонное решение linux-32 (для tests/selftest.sh)
set -euo pipefail
R=/srv/shop
mkdir -p /root/answers
ww=$(find $R -type f -perm -o+w)
{
  echo "big_file=$(find $R -type f -size +100M)"
  echo "recent_configs=$(find $R -type f -name '*.conf' -mtime -1 | sort | paste -sd,)"
  echo "world_writable=$ww"
  echo "orphan_file=$(find $R -nouser)"
} > /root/answers/linux-32.txt
chmod o-w "$ww"
