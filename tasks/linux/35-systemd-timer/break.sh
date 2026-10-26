#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-35
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit healthcheck.timer healthcheck.service health-check.service
rm -f /var/log/healthcheck.log
cat > /usr/local/bin/healthcheck.sh <<'EOF'
#!/bin/bash
# Простая проверка здоровья сервера
echo "$(date -Is) STATUS: OK load=$(cut -d' ' -f1 /proc/loadavg)" >> /var/log/healthcheck.log
EOF
chmod 0644 /usr/local/bin/healthcheck.sh

write_unit healthcheck.service <<'EOF'
[Unit]
Description=Server health check

[Service]
Type=oneshot
ExecStart=/usr/local/bin/healthcheck.sh
EOF

write_unit healthcheck.timer <<'EOF'
[Unit]
Description=Run health check every minute

[Timer]
OnCalendar=*-*-* 00:*:00
Unit=health-check.service

[Install]
WantedBy=timers.target
EOF
