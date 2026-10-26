#!/usr/bin/env bash
set -euo pipefail
TASK_ID=docker-05
. "$(dirname "$0")/../../../lib/common.sh"

APP=/opt/trainer-docker/reports-api
docker rm -f reports-api-check >/dev/null 2>&1 || true
rm -rf "$APP"
mkdir -p "$APP/test-data"
cp "$TRAINER_ROOT/lib/apps/webapp.py" "$APP/app.py"
echo "requests==2.32.3" > "$APP/requirements.txt"
for i in 1 2 3; do head -c 100M /dev/urandom > "$APP/test-data/dump-$i.sql"; done
cat > "$APP/Dockerfile" <<'EOF'
FROM ubuntu:24.04
RUN apt-get update
RUN apt-get install -y python3 python3-pip build-essential
COPY . /app
WORKDIR /app
RUN pip3 install --break-system-packages -r requirements.txt
ENV NAME=reports-api PORT=8000
EXPOSE 8000
CMD ["python3", "app.py"]
EOF
