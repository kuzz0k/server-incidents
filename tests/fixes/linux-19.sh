#!/usr/bin/env bash
# Эталонное решение linux-19 (для tests/selftest.sh)
set -euo pipefail
sed -i 's/^CACHE_MB=.*/CACHE_MB=32/' /etc/imagecache.conf
systemctl restart imagecache
sleep 2
