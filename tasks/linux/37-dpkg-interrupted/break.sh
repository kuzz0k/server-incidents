#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-37
. "$(dirname "$0")/../../../lib/common.sh"

if dpkg-query -W checkout-agent >/dev/null 2>&1; then
  rm -f /var/lib/dpkg/info/checkout-agent.prerm /var/lib/dpkg/info/checkout-agent.postrm
  dpkg --purge --force-all checkout-agent >/dev/null 2>&1 || true
fi
systemctl stop checkout-agent >/dev/null 2>&1 || true
remove_user checkout
getent group checkout >/dev/null && groupdel checkout
rm -rf /etc/checkout-agent

b=$TASK_VAR/build/checkout-agent
rm -rf "$TASK_VAR/build"
mkdir -p "$b/DEBIAN" "$b/usr/lib/checkout-agent" "$b/usr/share/checkout-agent" "$b/lib/systemd/system"
cp "$TRAINER_ROOT/lib/apps/webapp.py" "$b/usr/lib/checkout-agent/agent.py"
cat > "$b/DEBIAN/control" <<'EOF'
Package: checkout-agent
Version: 1.0.0
Architecture: all
Maintainer: Vendor Ops <ops@vendor.example>
Depends: python3
Description: Checkout agent
 Agent that syncs checkout events.
EOF
cat > "$b/usr/share/checkout-agent/agent.env.example" <<'EOF'
NAME=checkout-agent
PORT=8037
EOF
cat > "$b/lib/systemd/system/checkout-agent.service" <<'EOF'
[Unit]
Description=Checkout agent
After=network.target

[Service]
User=checkout
EnvironmentFile=/etc/checkout-agent/agent.env
ExecStart=/usr/bin/python3 /usr/lib/checkout-agent/agent.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
cat > "$b/DEBIAN/postinst" <<'EOF'
#!/bin/sh
set -e
if [ "$1" = configure ]; then
  if [ ! -f /etc/checkout-agent/agent.env ]; then
    echo "checkout-agent: /etc/checkout-agent/agent.env not found (see /usr/share/checkout-agent/)" >&2
    exit 1
  fi
  if ! id checkout >/dev/null 2>&1; then
    echo "checkout-agent: system user 'checkout' does not exist" >&2
    exit 1
  fi
  systemctl daemon-reload || true
  systemctl enable --now checkout-agent.service
fi
EOF
cat > "$b/DEBIAN/prerm" <<'EOF'
#!/bin/sh
systemctl disable --now checkout-agent.service >/dev/null 2>&1 || true
EOF
cat > "$b/DEBIAN/postrm" <<'EOF'
#!/bin/sh
[ "$1" = purge ] && rm -rf /etc/checkout-agent
systemctl daemon-reload >/dev/null 2>&1 || true
EOF
chmod 0755 "$b/DEBIAN/postinst" "$b/DEBIAN/prerm" "$b/DEBIAN/postrm"
mkdir -p /var/cache/trainer
dpkg-deb --root-owner-group --build "$b" /var/cache/trainer/checkout-agent_1.0.0_all.deb >/dev/null
dpkg -i /var/cache/trainer/checkout-agent_1.0.0_all.deb >/dev/null 2>&1 || true
