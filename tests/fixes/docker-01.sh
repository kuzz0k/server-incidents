#!/usr/bin/env bash
# Эталонное решение docker-01 (для tests/selftest.sh)
set -euo pipefail
APP=/opt/trainer-docker/payments
sed -i 's|/app/server.py|/app/webapp.py|' "$APP/Dockerfile"
docker build -q -t trainer/payments:1.0 "$APP" >/dev/null
cat > "$APP/run.sh" <<'EOF'
#!/bin/bash
# Деплой payments-api
docker rm -f payments-api >/dev/null 2>&1
docker run -d --name payments-api --restart unless-stopped \
  -e DB_URL=postgres://payments@db.internal:5432/payments \
  -p 8201:8000 trainer/payments:1.0
EOF
