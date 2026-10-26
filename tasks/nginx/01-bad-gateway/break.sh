#!/usr/bin/env bash
set -euo pipefail
TASK_ID=nginx-01
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit shop-backend
write_unit shop-backend <<EOF
[Unit]
Description=Shop backend v2
After=network.target

[Service]
DynamicUser=yes
Environment=NAME=shop-backend BIND=127.0.0.1 PORT=9110 "BODY=shop backend v2"
ExecStart=/usr/bin/python3 $WEBAPP
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now shop-backend >/dev/null 2>&1
wait_for_port 9110

nginx_site shop <<'EOF'
upstream shop_backend {
    server 127.0.0.1:9101;
}

server {
    listen 8101;
    server_name _;

    location / {
        proxy_pass http://shop_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF
nginx_apply || die "nginx не применил конфиг"
