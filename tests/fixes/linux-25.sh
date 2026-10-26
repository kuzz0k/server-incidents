#!/usr/bin/env bash
# Эталонное решение linux-25 (для tests/selftest.sh)
set -euo pipefail
ip netns exec tr-client ip link set c0 up
ip netns exec tr-client ip addr flush dev c0
ip netns exec tr-client ip addr add 10.25.0.2/24 dev c0
ip netns exec tr-client ip route add default via 10.25.0.1
ip netns exec tr-router sysctl -qw net.ipv4.ip_forward=1
ip netns exec tr-backend ip route add 10.25.0.0/24 via 10.26.0.1
