#!/usr/bin/env bash
# Эталонное решение linux-28 (для tests/selftest.sh)
set -euo pipefail
rm -f /etc/apt/sources.list.d/vendor-tools.list
systemctl disable --now apt-autoupdate
DEBIAN_FRONTEND=noninteractive apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq jq tree >/dev/null
