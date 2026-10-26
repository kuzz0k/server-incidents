#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-39
. "$(dirname "$0")/../../../lib/common.sh"

mkdir -p /srv/inventory
python3 - /srv/inventory/servers.json <<'EOF'
import json, random, sys
rnd = random.Random(39)
roles = ["web", "api", "db", "cache", "queue"]
servers, used = [], set()
for i in range(70):
    role = rnd.choice(roles)
    while True:
        name = f"{role}-{rnd.randint(1, 99):02d}"
        if name not in used:
            used.add(name)
            break
    servers.append({
        "name": name,
        "dc": rnd.choice(["msk-1", "msk-1", "msk-2", "spb-1"]),
        "ip": f"10.{rnd.randint(0, 3)}.{rnd.randint(0, 255)}.{rnd.randint(1, 254)}",
        "cpu_load": rnd.randint(1, 100),
        "status": rnd.choices(["up", "down", "maintenance"], [8, 1, 1])[0],
        "tags": sorted(set([role] + rnd.sample(["prod", "stage", "ssd", "legacy", "db"], rnd.randint(0, 2)))),
    })
rnd.shuffle(servers)
json.dump(servers, open(sys.argv[1], "w"), indent=2)
EOF
rm -f "$ANSWERS_DIR/linux-39.csv"
