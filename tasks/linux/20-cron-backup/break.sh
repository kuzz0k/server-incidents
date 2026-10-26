#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-20
. "$(dirname "$0")/../../../lib/common.sh"

systemctl enable --now cron >/dev/null 2>&1 || true
rm -f /etc/cron.d/db-backup /etc/cron.d/db-backup.cron
rm -rf /var/backups/db /opt/backup /var/lib/fake-db
rm -f /var/log/db-backup-*.log
mkdir -p /var/backups/db /opt/backup /var/lib/fake-db
head -c 1M /dev/urandom > /var/lib/fake-db/base.dat
echo "2026-10-21 orders snapshot" > /var/lib/fake-db/meta.txt

cat > /opt/backup/db-backup.sh <<'EOF'
#!/bin/bash
# Бэкап тестовой базы
set -euo pipefail
ts=$(date +%Y%m%d-%H%M%S)
tar czf "/var/backups/db/db-$ts.tar.gz" -C /var/lib/fake-db .
echo "$(date -Is) backup db-$ts.tar.gz done"
EOF
chmod 0644 /opt/backup/db-backup.sh

cat > /etc/cron.d/db-backup.cron <<'EOF'
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
* * * * * /opt/backup/db-backup.sh > /var/log/db-backup-$(date +%F).log 2>&1
EOF
chmod 0644 /etc/cron.d/db-backup.cron
