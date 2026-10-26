#!/usr/bin/env bash
# Эталонное решение docker-07 (для tests/selftest.sh)
set -euo pipefail
cat > /opt/trainer-docker/proxy/run.sh <<'EOF'
#!/bin/bash
# Запуск api и web (nginx-прокси)
cd "$(dirname "$0")"
docker build -q -t trainer/api:1.0 ./api >/dev/null
docker rm -f api web >/dev/null 2>&1
docker network inspect trainer-net >/dev/null 2>&1 || docker network create trainer-net >/dev/null
docker run -d --name api --network trainer-net --restart unless-stopped trainer/api:1.0
docker run -d --name web --network trainer-net --restart unless-stopped -p 8207:80 \
  -v "$PWD/nginx.conf:/etc/nginx/conf.d/default.conf:ro" nginx:1.27-alpine
EOF
