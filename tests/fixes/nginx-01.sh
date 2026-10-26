#!/usr/bin/env bash
# Эталонное решение nginx-01 (для tests/selftest.sh)
set -euo pipefail
sed -i 's/127.0.0.1:9101/127.0.0.1:9110/' /etc/nginx/sites-available/shop
nginx -t && systemctl reload nginx
sleep 2
