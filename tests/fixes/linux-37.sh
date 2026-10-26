#!/usr/bin/env bash
# Эталонное решение linux-37 (для tests/selftest.sh)
set -euo pipefail
useradd --system --no-create-home --shell /usr/sbin/nologin checkout
mkdir -p /etc/checkout-agent
cp /usr/share/checkout-agent/agent.env.example /etc/checkout-agent/agent.env
dpkg --configure -a
sleep 2
