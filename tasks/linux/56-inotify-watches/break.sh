#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-56
. "$(dirname "$0")/../../../lib/common.sh"

ensure_pkgs inotify-tools
remove_unit file-sync
remember max-watches "$(sysctl -n fs.inotify.max_user_watches)"
remember sysctl-d-files "$(ls /etc/sysctl.d 2>/dev/null | tr '\n' ' ')"
save_original /etc/sysctl.conf
{ grep -rlsE '^\s*fs\.inotify\.max_user_watches' /etc/sysctl.conf /etc/sysctl.d/ || true; } | while read -r f; do
  sed -i -E 's/^(\s*fs\.inotify\.max_user_watches)/# trainer-linux-56: \1/' "$f"
done

rm -rf /srv/sync-data
for a in $(seq 1 30); do
  for b in $(seq 1 100); do mkdir -p "/srv/sync-data/client-$a/order-$b"; done
done
find /srv/sync-data -type d | wc -l > "$TASK_VAR/dirs"
sysctl -qw fs.inotify.max_user_watches=512

write_unit file-sync <<'EOF'
[Unit]
Description=File sync watcher
After=local-fs.target

[Service]
ExecStart=/usr/bin/inotifywait -m -r -q -e close_write,moved_to /srv/sync-data
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now file-sync >/dev/null 2>&1 || true
