#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-25
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit tr-netns-backend
for ns in tr-client tr-router tr-backend; do ip netns del "$ns" 2>/dev/null || true; done
for ns in tr-client tr-router tr-backend; do ip netns add "$ns"; ip -n "$ns" link set lo up; done

ip link add c0 netns tr-client type veth peer name r0 netns tr-router
ip link add r1 netns tr-router type veth peer name b0 netns tr-backend

ip -n tr-router addr add 10.25.0.1/24 dev r0
ip -n tr-router addr add 10.26.0.1/24 dev r1
ip -n tr-router link set r0 up
ip -n tr-router link set r1 up
ip netns exec tr-router sysctl -qw net.ipv4.ip_forward=0

ip -n tr-backend addr add 10.26.0.2/24 dev b0
ip -n tr-backend link set b0 up

ip -n tr-client addr add 10.25.0.2/32 dev c0

mkdir -p /opt/netns-lab/www
echo "backend ok" > /opt/netns-lab/www/index.html
write_unit tr-netns-backend <<EOF
[Unit]
Description=devops-trainer linux-25: backend in netns

[Service]
ExecStart=$(command -v ip) netns exec tr-backend /usr/bin/python3 -m http.server 8080 --bind 10.26.0.2 --directory /opt/netns-lab/www
Restart=on-failure
EOF
systemctl start tr-netns-backend
wait_until 10 ip netns exec tr-backend curl -fs http://10.26.0.2:8080/ || die "backend в tr-backend не поднялся"
