#!/usr/bin/env bash
# Эталонное решение nginx-04 (для tests/selftest.sh)
set -euo pipefail
cat > /etc/nginx/sites-available/api <<'EOF'
server {
    listen 8104;
    server_name _;
    client_max_body_size 10m;

    location /api/ {
        proxy_pass http://127.0.0.1:9104/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF
nginx -t && systemctl reload nginx
sleep 2
