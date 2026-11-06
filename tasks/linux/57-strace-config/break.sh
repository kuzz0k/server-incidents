#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-57
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit geo-api
rm -rf /opt/geo-api /etc/geo /etc/geo-api.conf
mkdir -p /opt/geo-api
cat > /etc/geo-api.conf <<'EOF'
# geo-api settings
NAME=geo-api
PORT=8057
PROVIDER=osm
EOF
cat > /opt/geo-api/geo-api.py <<EOF
#!/usr/bin/env python3
# geo-api 2.0 (сборка вендора)
import os, runpy, sys
for path in (os.environ.get("GEO_CONFIG", ""), "/etc/geo/geo-api.conf", os.path.expanduser("~/.geo-api.conf")):
    try:
        if path and open(path).read():
            os.environ["CONFIG"] = path
            break
    except OSError:
        pass
else:
    print("configuration error, exiting", file=sys.stderr, flush=True)
    sys.exit(1)
os.environ.setdefault("REQUIRE", "PROVIDER")
runpy.run_path("$WEBAPP", run_name="__main__")
EOF
write_unit geo-api <<'EOF'
[Unit]
Description=Geocoding API (vendor)
After=network.target

[Service]
DynamicUser=yes
ExecStart=/usr/bin/python3 /opt/geo-api/geo-api.py
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now geo-api >/dev/null 2>&1 || true
sha256sum /etc/geo-api.conf | cut -d' ' -f1 > "$TASK_VAR/conf.sha256"
