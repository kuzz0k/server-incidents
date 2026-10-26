#!/usr/bin/env bash
set -euo pipefail
TASK_ID=nginx-04
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit api-backend
write_unit api-backend <<EOF
[Unit]
Description=API backend
After=network.target

[Service]
DynamicUser=yes
Environment=NAME=api-backend BIND=127.0.0.1 PORT=9104 ROUTES=/v1/,/upload REQUIRE_HEADER=X-Forwarded-For "BODY=users: alice bob"
ExecStart=/usr/bin/python3 $WEBAPP
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now api-backend >/dev/null 2>&1
wait_for_port 9104

nginx_site api <<'EOF'
server {
    listen 8104;
    server_name _;

    location /api/ {
        proxy_pass http://127.0.0.1:9104;
        proxy_set_header Host $host;
    }
}
EOF
nginx_apply || die "nginx не применил конфиг"
