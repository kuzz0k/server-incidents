#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-30
. "$(dirname "$0")/../../../lib/common.sh"

if [[ -f /usr/local/bin/backup-app.sh ]]; then
  mv /usr/local/bin/backup-app.sh "/usr/local/bin/backup-app.sh.bak-$(date +%s)"
  warn "Старый /usr/local/bin/backup-app.sh сохранён рядом как .bak"
fi
rm -rf /srv/app-data /var/backups/app-data
mkdir -p "/srv/app-data/uploads/2026 october" /srv/app-data/config
echo "db_host=10.0.0.5" > /srv/app-data/config/app.ini
echo "invoice" > "/srv/app-data/uploads/2026 october/invoice 001.pdf"
head -c 200K /dev/urandom > /srv/app-data/uploads/photo.jpg
