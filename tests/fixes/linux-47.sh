#!/usr/bin/env bash
# Эталонное решение linux-47 (для tests/selftest.sh)
set -euo pipefail
mkdir -p /etc/systemd/system/cache-rotate.service.d
printf '[Service]\nExecStart=\nExecStart=/bin/bash /srv/tools/rotate-cache.sh\n' > /etc/systemd/system/cache-rotate.service.d/override.conf
systemctl daemon-reload
systemctl start cache-rotate
