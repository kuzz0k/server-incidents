#!/usr/bin/env bash
set -euo pipefail
TASK_ID=nginx-06
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit shop-a shop-b shop-c
declare -A PORTS=([a]=9161 [b]=9162 [c]=9163)
for n in a b c; do
  port=${PORTS[$n]}
  write_unit "shop-$n" <<EOF
[Unit]
Description=Shop backend $n

[Service]
DynamicUser=yes
Environment=NAME=shop-$n BIND=127.0.0.1 PORT=$port "BODY=shop backend $n" SLOW=/report:7
ExecStart=/usr/bin/python3 $WEBAPP
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
done
systemctl enable --now shop-a shop-b >/dev/null 2>&1
wait_for_port 9161 && wait_for_port 9162

nginx_site shop-lb <<'EOF'
upstream shop_pool {
    server 127.0.0.1:9161;
    server 127.0.0.1:9162;
    server 127.0.0.1:9163;
}

server {
    listen 8106;
    server_name _;
    proxy_connect_timeout 2s;
    proxy_read_timeout 5s;
    proxy_next_upstream off;

    location / {
        proxy_pass http://shop_pool;
    }
}
EOF
nginx_apply || die "nginx не применил конфиг"
