#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-11
. "$(dirname "$0")/../../../lib/common.sh"

for f in /etc/payment/config.yml /var/log/payment/audit.log; do
  [[ -e $f ]] && chattr -ia "$f"
done
rm -rf /etc/payment /var/log/payment /opt/payment
mkdir -p /etc/payment /var/log/payment /opt/payment

cat > /etc/payment/config.yml <<'EOF'
gateway:
  url: https://pay.internal/api
timeout: 5
retries: 3
EOF
chmod 0644 /etc/payment/config.yml
chattr +i /etc/payment/config.yml

echo "2026-09-14T10:02:11+00:00 deploy timeout=5 by=ops" > /var/log/payment/audit.log
chattr +a /var/log/payment/audit.log

cat > /opt/payment/deploy.sh <<'EOF'
#!/bin/bash
# Обновляет таймаут платёжного шлюза и пишет запись в журнал аудита
set -e
sed -i 's/^timeout:.*/timeout: 30/' /etc/payment/config.yml
echo "$(date -Is) deploy timeout=30 by=$(whoami)" >> /var/log/payment/audit.log
echo "deploy ok"
EOF
chmod 0755 /opt/payment/deploy.sh
