#!/usr/bin/env bash
# Эталонное решение linux-54 (для tests/selftest.sh)
set -euo pipefail
mkdir -p /etc/systemd/system/ldap-proxy.service.d
printf '[Service]\nAmbientCapabilities=CAP_NET_BIND_SERVICE\nCapabilityBoundingSet=CAP_NET_BIND_SERVICE\n' \
  > /etc/systemd/system/ldap-proxy.service.d/override.conf
systemctl daemon-reload
systemctl reset-failed ldap-proxy || true
systemctl restart ldap-proxy
sleep 2
