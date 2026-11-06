#!/usr/bin/env bash
# Эталонное решение linux-49 (для tests/selftest.sh)
set -euo pipefail
mkdir -p /etc/systemd/system/job-runner.service.d
printf '[Service]\nTasksMax=256\n' > /etc/systemd/system/job-runner.service.d/override.conf
systemctl daemon-reload
systemctl reset-failed job-runner || true
systemctl restart job-runner
sleep 3
