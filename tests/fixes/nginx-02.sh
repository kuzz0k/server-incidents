#!/usr/bin/env bash
# Эталонное решение nginx-02 (для tests/selftest.sh)
set -euo pipefail
sed -i 's/^server_tokens off$/server_tokens off;/' /etc/nginx/conf.d/security.conf
systemctl disable --now old-landing
systemctl restart nginx
