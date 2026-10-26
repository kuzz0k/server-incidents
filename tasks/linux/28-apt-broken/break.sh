#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-28
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit apt-autoupdate
rm -f /etc/apt/sources.list.d/vendor-tools.list
mkdir -p "$TRAINER_LIB"
cat > "$TRAINER_LIB/apt-autoupdate.py" <<'EOF'
#!/usr/bin/env python3
# «Агент автообновлений»: берёт блокировку dpkg и ничего не делает
import fcntl
import os
import time

with open("/proc/self/comm", "w") as f:
    f.write("apt-autoupdate")
fd = os.open("/var/lib/dpkg/lock-frontend", os.O_RDWR | os.O_CREAT, 0o640)
fcntl.lockf(fd, fcntl.LOCK_EX)
while True:
    time.sleep(3600)
EOF

write_unit apt-autoupdate <<EOF
[Unit]
Description=Vendor automatic update agent
After=network-online.target

[Service]
ExecStart=/usr/bin/python3 $TRAINER_LIB/apt-autoupdate.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now apt-autoupdate >/dev/null 2>&1

cat > /etc/apt/sources.list.d/vendor-tools.list <<'EOF'
deb [arch=amd64 trusted=yes http://packages.vendor-tools.example/ubuntu stable main
EOF
