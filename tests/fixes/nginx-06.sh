#!/usr/bin/env bash
# Эталонное решение nginx-06 (для tests/selftest.sh): конфиг из SOLUTION.md
set -euo pipefail
sed -n '/^```nginx$/,/^```$/p' "$(dirname "$0")/../../tasks/nginx/06-load-balancer/SOLUTION.md" | sed '1d;$d' > /etc/nginx/sites-available/shop-lb
nginx -t && systemctl reload nginx
sleep 2
