#!/usr/bin/env bash
# Эталонное решение linux-21 (для tests/selftest.sh)
set -euo pipefail
ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
rm -f /etc/systemd/resolved.conf.d/90-corp-dns.conf
systemctl restart systemd-resolved
sleep 2
