#!/usr/bin/env bash
# Эталонное решение linux-13 (для tests/selftest.sh)
set -euo pipefail
sed -i 's/^cache_ttl 300$/CACHE_TTL=300/; s/^DB_HSOT=/DB_HOST=/' /etc/catalog/catalog.conf
systemctl reset-failed catalog
systemctl start catalog
sleep 2
