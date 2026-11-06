#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-49
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit job-runner
mkdir -p "$TRAINER_LIB"
cat > "$TRAINER_LIB/job-runner.py" <<'EOF'
#!/usr/bin/env python3
# Обработчик задач: пул рабочих потоков + HTTP /health
import os, threading, time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

def worker(n):
    while True:
        time.sleep(1)

workers = int(os.environ.get("WORKERS", "4"))
for i in range(workers):
    threading.Thread(target=worker, args=(i,), daemon=True).start()
print(f"started {workers} workers", flush=True)

class Health(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200 if self.path == "/health" else 404)
        self.end_headers()
        self.wfile.write(b"ok\n")
    def log_message(self, *a):
        pass

ThreadingHTTPServer(("0.0.0.0", int(os.environ.get("PORT", "8049"))), Health).serve_forever()
EOF

write_unit job-runner <<EOF
[Unit]
Description=Job runner
After=network.target

[Service]
DynamicUser=yes
Environment=WORKERS=40 PORT=8049
ExecStart=/usr/bin/python3 $TRAINER_LIB/job-runner.py
TasksMax=16
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now job-runner >/dev/null 2>&1 || true
