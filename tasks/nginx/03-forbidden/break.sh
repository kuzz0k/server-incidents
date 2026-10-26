#!/usr/bin/env bash
set -euo pipefail
TASK_ID=nginx-03
. "$(dirname "$0")/../../../lib/common.sh"

rm -rf /srv/www/blog /srv/media/images
mkdir -p /srv/www/blog /srv/media/images
echo "<h1>DevOps blog</h1><img src=/images/logo.png>" > /srv/www/blog/index.htm
printf '\x89PNG\r\n\x1a\n' > /srv/media/images/logo.png
head -c 2K /dev/urandom >> /srv/media/images/logo.png
chmod 0644 /srv/www/blog/index.htm /srv/media/images/logo.png
chmod 0755 /srv/www/blog /srv/media /srv/media/images
chown root:root /srv/www
chmod 0700 /srv/www

nginx_site blog <<'EOF'
server {
    listen 8103;
    server_name _;
    root /srv/www/blog;
    index index.html;

    location /images/ {
        alias /srv/media/images;
    }
}
EOF
nginx_apply || die "nginx не применил конфиг"
