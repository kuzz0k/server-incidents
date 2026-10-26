#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-42
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit log-flood
mkdir -p /var/log/journal /etc/systemd/journald.conf.d
systemd-tmpfiles --create --prefix /var/log/journal >/dev/null 2>&1 || true
cat > /etc/systemd/journald.conf.d/90-retention.conf <<'EOF'
# keep logs as long as possible (OPS-77)
[Journal]
Storage=persistent
SystemMaxUse=8G
SystemKeepFree=1G
EOF
systemctl restart systemd-journald
journalctl --flush >/dev/null 2>&1 || true

cat > "$TASK_VAR/journal_mb.py" <<'EOF'
import re, subprocess
out = subprocess.run(["journalctl", "--disk-usage"], capture_output=True, text=True).stdout
m = re.search(r"([0-9.]+)\s*([BKMGT])", out)
print(int(float(m.group(1)) * {"B": 1 / 2**20, "K": 1 / 1024, "M": 1, "G": 1024, "T": 2**20}[m.group(2)]) if m else 0)
EOF
need=$(( $(python3 "$TASK_VAR/journal_mb.py") + 300 ))
info "Наполняю журнал (~350 МБ)…"
mkdir -p "$TRAINER_LIB"
cat > "$TRAINER_LIB/log-flood.py" <<'EOF'
#!/usr/bin/env python3
# Генерирует много несжимаемых строк лога
import base64, os, sys
for _ in range(1_200_000):
    sys.stdout.write("DEBUG payload=" + base64.b64encode(os.urandom(180)).decode() + "\n")
EOF
write_unit log-flood <<EOF
[Service]
Type=oneshot
ExecStart=/usr/bin/python3 $TRAINER_LIB/log-flood.py
LogRateLimitIntervalSec=0
TimeoutStartSec=600
EOF
systemctl start log-flood
wait_until 300 bash -c "(( \$(python3 $TASK_VAR/journal_mb.py) >= $need ))" || true
remove_unit log-flood
