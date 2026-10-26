#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-36
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit notes-api
remove_user notes
getent group notes >/dev/null && groupdel notes
rm -rf /opt/notes-api /etc/notes-api /var/lib/notes-api /var/lib/private/notes-api
mkdir -p /opt/notes-api /etc/notes-api
cp "$TRAINER_ROOT/lib/apps/webapp.py" /opt/notes-api/server.py
chmod 0755 /opt/notes-api/server.py
cat > /etc/notes-api/notes-api.env <<'EOF'
NAME=notes-api
PORT=8036
DATA_DIR=/var/lib/notes-api
EOF
