#!/usr/bin/env bash
set -euo pipefail
TASK_ID=docker-07
. "$(dirname "$0")/../../../lib/common.sh"

APP=/opt/trainer-docker/proxy
docker rm -f api web >/dev/null 2>&1 || true
docker network rm trainer-net >/dev/null 2>&1 || true
rm -rf "$APP"
mkdir -p "$APP/api"
cp "$TRAINER_ROOT/lib/apps/webapp.py" "$APP/api/webapp.py"
cat > "$APP/api/Dockerfile" <<'EOF'
FROM python:3.12-alpine
COPY webapp.py /app/webapp.py
ENV NAME=api PORT=8000 BODY="hello from api"
CMD ["python3", "/app/webapp.py"]
EOF
cat > "$APP/nginx.conf" <<'EOF'
server {
    listen 80;
    location / {
        proxy_pass http://api:8000;
    }
}
EOF
cat > "$APP/run.sh" <<'EOF'
#!/bin/bash
# Запуск api и web (nginx-прокси)
cd "$(dirname "$0")"
docker build -q -t trainer/api:1.0 ./api >/dev/null
docker rm -f api web >/dev/null 2>&1
docker run -d --name api --restart unless-stopped trainer/api:1.0
docker run -d --name web --restart unless-stopped -p 8207:80 \
  -v "$PWD/nginx.conf:/etc/nginx/conf.d/default.conf:ro" nginx:1.27-alpine
EOF
chmod 0755 "$APP/run.sh"
sha256sum "$APP/nginx.conf" > "$TASK_VAR/nginx.sha256"
info "Собираю и запускаю api и web…"
"$APP/run.sh" >/dev/null
