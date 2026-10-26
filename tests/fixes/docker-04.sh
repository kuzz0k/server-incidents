#!/usr/bin/env bash
# Эталонное решение docker-04 (для tests/selftest.sh)
set -euo pipefail
docker container prune -f >/dev/null
docker image prune -f >/dev/null
python3 - <<'EOF'
import json, os
p = "/etc/docker/daemon.json"
c = json.load(open(p)) if os.path.exists(p) else {}
c["log-driver"] = "json-file"
c.setdefault("log-opts", {}).update({"max-size": "10m", "max-file": "3"})
os.makedirs("/etc/docker", exist_ok=True)
json.dump(c, open(p, "w"), indent=2)
EOF
systemctl restart docker
/opt/trainer-docker/chatty/run.sh >/dev/null
