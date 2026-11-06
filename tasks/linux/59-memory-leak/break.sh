#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-59
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit cache-warmer search-indexer
mkdir -p "$TRAINER_LIB"
cat > "$TRAINER_LIB/cache-warmer.py" <<'EOF'
#!/usr/bin/env python3
# Прогрев кеша. Баг: ничего не выбрасывает из кеша, память растёт (до ~400 МБ)
import time
cache = []
while True:
    if len(cache) < 200:
        block = bytearray(2 * 1024 * 1024)
        for i in range(0, len(block), 4096):
            block[i] = 1
        cache.append(block)
    time.sleep(0.15)
EOF
write_unit cache-warmer <<EOF
[Unit]
Description=Cache warmer

[Service]
DynamicUser=yes
ExecStart=/usr/bin/python3 $TRAINER_LIB/cache-warmer.py

[Install]
WantedBy=multi-user.target
EOF
write_unit search-indexer <<EOF
[Unit]
Description=Search indexer

[Service]
DynamicUser=yes
Environment=NAME=search-indexer PORT=8059 CACHE_MB=120
ExecStart=/usr/bin/python3 $WEBAPP

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now cache-warmer search-indexer >/dev/null 2>&1
