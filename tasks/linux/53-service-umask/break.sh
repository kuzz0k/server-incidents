#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-53
. "$(dirname "$0")/../../../lib/common.sh"

D=/srv/reports
remove_unit report-exporter reports-web
remove_user exporter www-reports
remove_group reports
groupadd --system reports
useradd --system --no-create-home --shell /usr/sbin/nologin -G reports exporter
useradd --system --no-create-home --shell /usr/sbin/nologin -G reports www-reports
rm -rf "$D"
install -d -m 2770 -o exporter -g reports "$D"
mkdir -p "$TRAINER_LIB"
cat > "$TRAINER_LIB/report-exporter.py" <<'EOF'
#!/usr/bin/env python3
# Экспорт отчётов: каждые 2 секунды новый файл в /srv/reports, хранит последние 20
import glob, os, time
while True:
    name = f"/srv/reports/report-{time.strftime('%Y%m%d-%H%M%S')}.txt"
    with open(name, "w") as f:
        f.write(f"daily revenue report {time.ctime()}\n")
    for old in sorted(glob.glob("/srv/reports/report-*.txt"))[:-20]:
        os.remove(old)
    time.sleep(2)
EOF
cat > "$TRAINER_LIB/reports-web.py" <<'EOF'
#!/usr/bin/env python3
# Отдаёт последний отчёт на /latest
import glob
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

class H(BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            latest = sorted(glob.glob("/srv/reports/report-*.txt"))[-1]
            body, code = open(latest, "rb").read(), 200
        except Exception as e:
            print(f"ERROR {e}", flush=True)
            body, code = f"error: {e}\n".encode(), 500
        self.send_response(code)
        self.end_headers()
        self.wfile.write(body)
    def log_message(self, *a):
        pass

ThreadingHTTPServer(("0.0.0.0", 8053), H).serve_forever()
EOF

write_unit report-exporter <<EOF
[Unit]
Description=Report exporter

[Service]
User=exporter
Group=reports
UMask=0077
ExecStart=/usr/bin/python3 $TRAINER_LIB/report-exporter.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
write_unit reports-web <<EOF
[Unit]
Description=Reports web

[Service]
User=www-reports
Group=www-reports
SupplementaryGroups=reports
ExecStart=/usr/bin/python3 $TRAINER_LIB/reports-web.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now report-exporter reports-web >/dev/null 2>&1
wait_for_port 8053
sleep 3
