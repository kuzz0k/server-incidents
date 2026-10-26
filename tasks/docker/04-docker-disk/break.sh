#!/usr/bin/env bash
set -euo pipefail
TASK_ID=docker-04
. "$(dirname "$0")/../../../lib/common.sh"

(( $(df --output=avail -m /var/lib/docker | tail -1) > 2000 )) || die "В /var/lib/docker меньше 2 ГБ свободного места"

docker rm -f chatty >/dev/null 2>&1 || true
docker ps -aq --filter 'name=^junk-' | xargs -r docker rm -f >/dev/null
docker pull -q alpine:3.20 >/dev/null
docker tag alpine:3.20 trainer/keep:prod

info "Создаю мусорные образы и контейнеры…"
w=$(mktemp -d)
cat > "$w/Dockerfile" <<'EOF'
FROM alpine:3.20
ARG N=0
RUN dd if=/dev/urandom of=/blob-$N bs=1M count=15 2>/dev/null
EOF
for i in $(seq 1 15); do
  docker build -q --no-cache --build-arg N="$i" -t trainer/junk:latest "$w" >/dev/null
done
docker rmi trainer/junk:latest >/dev/null 2>&1 || true
rm -rf "$w"
for i in $(seq 1 30); do docker run --name "junk-$i" alpine:3.20 true >/dev/null; done

mkdir -p /opt/trainer-docker/chatty
cat > /opt/trainer-docker/chatty/run.sh <<'EOF'
#!/bin/bash
# Запуск chatty — сервис с очень подробным логированием
docker rm -f chatty >/dev/null 2>&1
docker run -d --name chatty --restart unless-stopped alpine:3.20 \
  sh -c 'yes "$(date) DEBUG chatty: processing event id=42 status=ok payload=..." | head -n 1500000; while true; do echo "$(date) tick"; sleep 1; done'
EOF
chmod 0755 /opt/trainer-docker/chatty/run.sh
if [[ -f /etc/docker/daemon.json ]] && grep -q max-size /etc/docker/daemon.json; then
  warn "В /etc/docker/daemon.json уже есть max-size — эта часть задачи будет засчитана сразу"
fi
/opt/trainer-docker/chatty/run.sh >/dev/null
log=$(docker inspect -f '{{.LogPath}}' chatty)
wait_until 90 bash -c "(( \$(stat -c %s '$log' 2>/dev/null || echo 0) > 100000000 ))" || true
