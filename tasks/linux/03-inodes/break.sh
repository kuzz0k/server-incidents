#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-03
. "$(dirname "$0")/../../../lib/common.sh"

MP=/var/lib/sessions

install_webapp
remove_unit sessions
unmount_task "$TASK_ID" "$MP"
dev=$(make_disk linux03 200)
mkfs.ext4 -q -F -N 100000 -L sessions "$dev"
mount_disk "$TASK_ID" "$dev" "$MP"
ensure_user sessions
mkdir -p "$MP/store" "$MP/app"

# Заполняем inode пустыми файлами сессий; каждый 200-й — «свежий»
python3 - "$MP/store" "$TASK_VAR/fresh.txt" <<'EOF'
import errno, os, secrets, sys, time
store, fresh_list = sys.argv[1], sys.argv[2]
names = []
while len(names) < 150000:
    name = f"sess_{secrets.token_hex(16)}"
    try:
        os.close(os.open(os.path.join(store, name), os.O_CREAT | os.O_WRONLY, 0o600))
    except OSError as e:
        if e.errno == errno.ENOSPC:
            break
        raise
    names.append(name)
fresh = set(names[::200])
now = time.time()
for i, n in enumerate(names):
    if n not in fresh:
        t = now - 86400 * (2 + i % 28)
        os.utime(os.path.join(store, n), (t, t))
with open(fresh_list, "w") as f:
    f.write("\n".join(sorted(fresh)) + "\n")
EOF
chown -R sessions: "$MP"

write_unit sessions <<EOF
[Unit]
Description=Session storage service
After=network.target

[Service]
User=sessions
Environment=NAME=sessions PORT=8003 DATA_DIR=$MP/app
ExecStart=/usr/bin/python3 $WEBAPP
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now sessions >/dev/null 2>&1
wait_for_port 8003
