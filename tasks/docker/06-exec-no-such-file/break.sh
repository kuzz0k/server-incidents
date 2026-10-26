#!/usr/bin/env bash
set -euo pipefail
TASK_ID=docker-06
. "$(dirname "$0")/../../../lib/common.sh"

APP=/opt/trainer-docker/worker
docker rm -f worker >/dev/null 2>&1 || true
rm -rf "$APP"
mkdir -p "$APP"
cat > "$APP/Dockerfile" <<'EOF'
FROM alpine:3.20
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
EOF
cat > "$APP/entrypoint.sh" <<'EOF'
#!/bin/bash
echo "worker started"
while true; do
  sleep 5
  echo "$(date) tick"
done
EOF
sed -i 's/$/\r/' "$APP/entrypoint.sh"
cat > "$APP/run.sh" <<'EOF'
#!/bin/bash
# Сборка и запуск воркера
set -e
cd "$(dirname "$0")"
docker build -q -t trainer/worker:1.0 . >/dev/null
docker rm -f worker >/dev/null 2>&1 || true
docker run -d --name worker --restart unless-stopped trainer/worker:1.0
EOF
chmod 0755 "$APP/run.sh"
info "Собираю образ trainer/worker:1.0…"
"$APP/run.sh" >/dev/null
