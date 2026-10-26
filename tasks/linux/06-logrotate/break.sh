#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-06
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit billing-app
ensure_user billing
rm -rf /var/log/billing
install -d -m 0775 -o billing -g billing /var/log/billing
head -c 40M < <(yes "2026-10-01T12:00:00 INFO charge ok customer=4411 amount=19.90 currency=EUR") > /var/log/billing/billing.log
chown billing:billing /var/log/billing/billing.log
chmod 0640 /var/log/billing/billing.log

cat > /etc/logrotate.d/billing <<'EOF'
/var/log/billing/*.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 0640 billing billing
}
EOF

write_unit billing-app <<'EOF'
[Unit]
Description=Billing application
After=network.target

[Service]
User=billing
ExecStart=/bin/bash -c 'while true; do echo "$$(date -Is) INFO charge ok amount=9.90" >> /var/log/billing/billing.log; sleep 1; done'
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now billing-app >/dev/null 2>&1
