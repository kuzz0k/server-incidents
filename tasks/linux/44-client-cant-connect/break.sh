#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-44
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit orders-api order-sync
mkdir -p "$TRAINER_LIB"
write_unit orders-api <<EOF
[Unit]
Description=Orders API
After=network.target

[Service]
DynamicUser=yes
Environment=NAME=orders-api BIND=127.0.0.1 PORT=8044
ExecStart=/usr/bin/python3 $WEBAPP
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now orders-api >/dev/null 2>&1
wait_for_port 8044

cat > "$TRAINER_LIB/order-sync.py" <<'EOF'
#!/usr/bin/env python3
# Отправляет заказы в API. Ошибки логирует без подробностей (так написал вендор).
import os
import time
import urllib.request

url = f"http://{os.environ.get('API_HOST', '127.0.0.1')}:{os.environ.get('API_PORT', '80')}/health"
while True:
    try:
        urllib.request.urlopen(url, timeout=2).read()
        print("sync ok", flush=True)
    except Exception:
        print("ERROR upstream request failed", flush=True)
    time.sleep(1)
EOF
cat > /etc/default/order-sync <<'EOF'
# order-sync settings
API_HOST=127.0.0.1
API_PORT=8440
EOF
write_unit order-sync <<EOF
[Unit]
Description=Order sync client
After=network.target

[Service]
DynamicUser=yes
EnvironmentFile=/etc/default/order-sync
ExecStart=/usr/bin/python3 $TRAINER_LIB/order-sync.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now order-sync >/dev/null 2>&1
