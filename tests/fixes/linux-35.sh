#!/usr/bin/env bash
# Эталонное решение linux-35 (для tests/selftest.sh)
set -euo pipefail
chmod +x /usr/local/bin/healthcheck.sh
cat > /etc/systemd/system/healthcheck.timer <<'EOF'
[Unit]
Description=Run health check every minute

[Timer]
OnCalendar=*-*-* *:*:00
Persistent=true

[Install]
WantedBy=timers.target
EOF
systemctl daemon-reload
systemctl enable --now healthcheck.timer
