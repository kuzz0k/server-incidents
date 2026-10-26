#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-33
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit report-sync
mkdir -p /var/log/trainer "$TRAINER_LIB"
printf '%s report-sync started\n' "$(date -Is)" > /var/log/trainer/bad.log
cat > "$TRAINER_LIB/report-sync.py" <<'EOF'
#!/usr/bin/env python3
# Синхронизация отчётов (давно не нужна, но всё ещё пишет в лог)
import random
import time

log = open("/var/log/trainer/bad.log", "a", buffering=1)
while True:
    log.write(f"{time.strftime('%Y-%m-%dT%H:%M:%S')} sync chunk {random.randint(1, 99999)} ok\n")
    time.sleep(0.2)
EOF

write_unit report-sync <<EOF
[Unit]
Description=Report sync

[Service]
ExecStart=/usr/bin/python3 $TRAINER_LIB/report-sync.py
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now report-sync >/dev/null 2>&1
sleep 2
stat -c %s /var/log/trainer/bad.log > "$TASK_VAR/size"
