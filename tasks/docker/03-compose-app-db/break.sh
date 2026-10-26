#!/usr/bin/env bash
set -euo pipefail
TASK_ID=docker-03
. "$(dirname "$0")/../../../lib/common.sh"

APP=/opt/trainer-docker/notes
if [[ -f $APP/compose.yaml ]]; then
  (cd "$APP" && docker compose down -v --remove-orphans >/dev/null 2>&1) || true
fi
rm -rf "$APP"
mkdir -p "$APP/web"

cat > "$APP/web/app.py" <<'EOF'
#!/usr/bin/env python3
"""Сервис заметок: хранит заметки в PostgreSQL (через psql)."""
import os
import subprocess
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

DB_HOST = os.environ.get("DB_HOST", "localhost")
ENV = dict(os.environ, PGPASSWORD=os.environ.get("DB_PASSWORD", ""))
BASE = ["psql", "-h", DB_HOST, "-U", os.environ.get("DB_USER", "notes"),
        "-d", os.environ.get("DB_NAME", "notes"), "-XqAt", "-v", "ON_ERROR_STOP=1", "-c"]


def sql(query):
    r = subprocess.run(BASE + [query], env=ENV, capture_output=True, text=True, timeout=10)
    if r.returncode != 0:
        raise RuntimeError(r.stderr.strip())
    return r.stdout


class Handler(BaseHTTPRequestHandler):
    def reply(self, code, text):
        data = (text + "\n").encode()
        self.send_response(code)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        try:
            if self.path == "/health":
                sql("SELECT 1")
                self.reply(200, "ok")
            elif self.path == "/notes":
                self.reply(200, sql("SELECT id || ': ' || body FROM notes ORDER BY id").strip())
            else:
                self.reply(404, "not found")
        except Exception as e:
            self.reply(500, f"db error: {e}")

    def do_POST(self):
        if self.path != "/notes":
            self.reply(404, "not found")
            return
        body = self.rfile.read(int(self.headers.get("Content-Length") or 0)).decode()
        try:
            sql("INSERT INTO notes (body) VALUES ('" + body.replace("'", "''") + "')")
            self.reply(201, "saved")
        except Exception as e:
            self.reply(500, f"db error: {e}")


try:
    sql("CREATE TABLE IF NOT EXISTS notes (id serial PRIMARY KEY, body text NOT NULL)")
except Exception as e:
    print(f"FATAL: cannot connect to database at {DB_HOST}: {e}", file=sys.stderr, flush=True)
    sys.exit(1)
print("notes web listening on :8000", flush=True)
ThreadingHTTPServer(("0.0.0.0", 8000), Handler).serve_forever()
EOF

cat > "$APP/web/Dockerfile" <<'EOF'
FROM python:3.12-alpine
RUN apk add --no-cache postgresql-client
WORKDIR /app
COPY app.py .
CMD ["python3", "-u", "app.py"]
EOF

cat > "$APP/compose.yaml" <<'EOF'
services:
  web:
    build: ./web
    ports:
      - "8203:8000"
    environment:
      DB_HOST: localhost
      DB_USER: notes
      DB_PASSWORD: notes
      DB_NAME: notes
    depends_on:
      - db

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: notes
      POSTGRES_PASSWORD: notes
      POSTGRES_DB: notes
EOF
info "Собираю и запускаю стек notes…"
(cd "$APP" && docker compose up -d --build >/dev/null 2>&1) || true
