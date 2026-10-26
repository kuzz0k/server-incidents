#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-17
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit legacy-batch
mkdir -p "$TRAINER_LIB"
cat > "$TRAINER_LIB/legacy-batch.py" <<'EOF'
#!/usr/bin/env python3
# Устаревший пакетный обработчик: запускает воркеры и никогда не собирает их код возврата
import os
import time

for i in range(50):
    if os.fork() == 0:
        with open("/proc/self/comm", "w") as f:
            f.write("batch-worker")
        os._exit(0)
while True:
    time.sleep(3600)
EOF

write_unit legacy-batch <<EOF
[Unit]
Description=Legacy batch processor

[Service]
ExecStart=/usr/bin/python3 $TRAINER_LIB/legacy-batch.py
EOF
systemctl start legacy-batch
sleep 2
systemctl show -p MainPID --value legacy-batch > "$TASK_VAR/parent.pid"
