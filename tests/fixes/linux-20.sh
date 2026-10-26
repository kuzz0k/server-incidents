#!/usr/bin/env bash
# Эталонное решение linux-20 (для tests/selftest.sh)
set -euo pipefail
rm -f /etc/cron.d/db-backup.cron
cat > /etc/cron.d/db-backup <<'EOF'
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
* * * * * root /opt/backup/db-backup.sh > /var/log/db-backup-$(date +\%F).log 2>&1
EOF
chmod 644 /etc/cron.d/db-backup
chmod +x /opt/backup/db-backup.sh
