#!/usr/bin/env bash
# Эталонное решение linux-36 (для tests/selftest.sh): юнит из SOLUTION.md
set -euo pipefail
useradd --system --no-create-home --shell /usr/sbin/nologin notes
sed -n "/^cat > \/etc\/systemd\/system\/notes-api.service <<'EOF'$/,/^EOF$/p" \
  "$(dirname "$0")/../../tasks/linux/36-write-unit/SOLUTION.md" | sed '1d;$d' > /etc/systemd/system/notes-api.service
systemctl daemon-reload
systemctl enable --now notes-api
sleep 2
