#!/usr/bin/env bash
set -euo pipefail
TASK_ID=docker-02
. "$(dirname "$0")/../../../lib/common.sh"

APP=/opt/trainer-docker/catalog
docker rm -f catalog >/dev/null 2>&1 || true
rm -rf "$APP"
mkdir -p "$APP"
cp "$TRAINER_ROOT/lib/apps/webapp.py" "$APP/webapp.py"
cat > "$APP/Dockerfile" <<'EOF'
FROM python:3.12-alpine
WORKDIR /app
COPY webapp.py /app/webapp.py
ENV NAME=catalog BIND=127.0.0.1 PORT=5000
CMD ["python3", "/app/webapp.py"]
EOF
cat > "$APP/run.sh" <<'EOF'
#!/bin/bash
# Деплой catalog
docker rm -f catalog >/dev/null 2>&1
docker run -d --name catalog --restart unless-stopped -p 8202:8080 trainer/catalog:1.0
EOF
chmod 0755 "$APP/run.sh"
info "Собираю образ trainer/catalog:1.0…"
docker build -q -t trainer/catalog:1.0 "$APP" >/dev/null
rm -f "$APP/Dockerfile" "$APP/webapp.py"
"$APP/run.sh" >/dev/null
