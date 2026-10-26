#!/usr/bin/env bash
set -euo pipefail
TASK_ID=docker-01
. "$(dirname "$0")/../../../lib/common.sh"

APP=/opt/trainer-docker/payments
docker rm -f payments-api >/dev/null 2>&1 || true
rm -rf "$APP"
mkdir -p "$APP"
cp "$TRAINER_ROOT/lib/apps/webapp.py" "$APP/webapp.py"
cat > "$APP/Dockerfile" <<'EOF'
FROM python:3.12-alpine
WORKDIR /app
COPY webapp.py /app/webapp.py
ENV NAME=payments-api PORT=8000 REQUIRE=DB_URL
EXPOSE 8000
CMD ["python3", "/app/server.py"]
EOF
cat > "$APP/run.sh" <<'EOF'
#!/bin/bash
# Деплой payments-api
docker rm -f payments-api >/dev/null 2>&1
docker run -d --name payments-api -p 8201:8000 trainer/payments:1.0
EOF
chmod 0755 "$APP/run.sh"
info "Собираю образ trainer/payments:1.0…"
docker build -q -t trainer/payments:1.0 "$APP" >/dev/null
"$APP/run.sh" >/dev/null
