#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-21
. "$(dirname "$0")/../../../lib/common.sh"

getent hosts archive.ubuntu.com >/dev/null || die "DNS уже не работает — сначала почини его, иначе задачу не проверить"
systemctl is-active -q systemd-resolved || die "Задача рассчитана на systemd-resolved, а он не запущен"

mkdir -p /etc/systemd/resolved.conf.d
cat > /etc/systemd/resolved.conf.d/90-corp-dns.conf <<'EOF'
# Corporate DNS (OPS-2231)
[Resolve]
DNS=192.0.2.53
Domains=~.
EOF
systemctl restart systemd-resolved

rm -f /etc/resolv.conf
cat > /etc/resolv.conf <<'EOF'
# corporate resolver
nameserver 192.0.2.53
options timeout:2 attempts:1
EOF
resolvectl flush-caches 2>/dev/null || true
