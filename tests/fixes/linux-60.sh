#!/usr/bin/env bash
# Эталонное решение linux-60 (для tests/selftest.sh)
set -euo pipefail
chown -R media:media /srv/media-store
systemctl restart media-api
sleep 2
