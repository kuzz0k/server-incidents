#!/usr/bin/env bash
# Эталонное решение linux-38 (для tests/selftest.sh)
set -euo pipefail
iptables -t nat -A PREROUTING -p tcp --dport 8038 -j REDIRECT --to-ports 20280
iptables -t nat -A OUTPUT -p tcp -o lo --dport 8038 -j REDIRECT --to-ports 20280
