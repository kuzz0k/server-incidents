#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-16
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit thumbnailer
ensure_user thumbnailer
install -d -o thumbnailer -g thumbnailer /var/spool/thumbnailer
mkdir -p "$TRAINER_LIB"
cat > "$TRAINER_LIB/thumbnailer.py" <<'EOF'
#!/usr/bin/env python3
# Генератор превью: опрашивает каталог очереди и обрабатывает новые файлы
import os
import time

cfg = {}
with open("/etc/thumbnailer.conf") as f:
    for line in f:
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            k, v = line.split("=", 1)
            cfg[k.strip()] = v.strip()

queue = cfg.get("QUEUE_DIR", "/var/spool/thumbnailer")
interval = float(cfg.get("POLL_INTERVAL", "5"))
print(f"thumbnailer started, queue={queue} poll_interval={interval}", flush=True)
while True:
    for name in os.listdir(queue):
        path = os.path.join(queue, name)
        print(f"processing {path}", flush=True)
        os.remove(path)
    if interval > 0:
        time.sleep(interval)
EOF
cat > /etc/thumbnailer.conf <<'EOF'
# thumbnailer config
QUEUE_DIR=/var/spool/thumbnailer
# poll interval in seconds
POLL_INTERVAL=0
EOF

write_unit thumbnailer <<EOF
[Unit]
Description=Thumbnail generator
After=network.target

[Service]
User=thumbnailer
ExecStart=/usr/bin/python3 $TRAINER_LIB/thumbnailer.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now thumbnailer >/dev/null 2>&1
