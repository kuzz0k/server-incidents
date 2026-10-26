#!/usr/bin/env bash
set -euo pipefail
TASK_ID=nginx-02
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit old-landing
nginx_remove_site landing
rm -f /etc/nginx/conf.d/security.conf
nginx_apply || true
mkdir -p /srv/www/landing /opt/old-landing
echo "<h1>Autumn sale landing</h1>" > /srv/www/landing/index.html
echo "<h1>old landing 2019</h1>" > /opt/old-landing/index.html

write_unit old-landing <<'EOF'
[Unit]
Description=Old landing page (2019)
After=network.target

[Service]
DynamicUser=yes
ExecStart=/usr/bin/python3 -m http.server 8102 --directory /opt/old-landing
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now old-landing >/dev/null 2>&1
wait_for_port 8102

nginx_site landing <<'EOF'
server {
    listen 8102;
    server_name _;
    root /srv/www/landing;
    index index.html;
}
EOF
cat > /etc/nginx/conf.d/security.conf <<'EOF'
server_tokens off
add_header X-Frame-Options SAMEORIGIN always;
EOF
systemctl restart nginx >/dev/null 2>&1 || true
