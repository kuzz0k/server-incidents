#!/usr/bin/env bash
# Эталонное решение nginx-03 (для tests/selftest.sh)
set -euo pipefail
chmod 755 /srv/www
sed -i 's/index index.html;/index index.html index.htm;/' /etc/nginx/sites-available/blog
sed -i 's|alias /srv/media/images;|alias /srv/media/images/;|' /etc/nginx/sites-available/blog
nginx -t && systemctl reload nginx
sleep 2
