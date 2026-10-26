#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-02
. "$(dirname "$0")/../../../lib/common.sh"

MP=/var/lib/metrics

remove_unit metrics-agent
unmount_task "$TASK_ID" "$MP"
dev=$(make_disk linux02 300)
mkfs.ext4 -q -F -L metrics "$dev"
mount_disk "$TASK_ID" "$dev" "$MP"
ensure_user metrics

head -c 200M < <(yes "2026-10-20T10:00:00 metric cpu.load=0.42 mem.used=61% host=web-01") > "$MP/agent.log"
chown -R metrics: "$MP"

mkdir -p "$TRAINER_LIB"
cat > "$TRAINER_LIB/metrics-agent.py" <<'EOF'
#!/usr/bin/env python3
# Агент сбора метрик: раз в 2 секунды дописывает строку в лог
import os
import time

log = open("/var/lib/metrics/agent.log", "a", buffering=1)
while True:
    try:
        log.write(f"{time.strftime('%Y-%m-%dT%H:%M:%S')} metric cpu.load={os.getloadavg()[0]:.2f}\n")
    except OSError as e:
        print(f"WARN cannot write metrics: {e}", flush=True)
    time.sleep(2)
EOF

write_unit metrics-agent <<EOF
[Unit]
Description=Metrics collection agent
After=network.target

[Service]
User=metrics
ExecStart=/usr/bin/python3 $TRAINER_LIB/metrics-agent.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now metrics-agent >/dev/null 2>&1
sleep 2
rm -f "$MP/agent.log"
