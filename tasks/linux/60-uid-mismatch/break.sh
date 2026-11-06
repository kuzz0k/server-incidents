#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-60
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit media-api
remove_user media
remove_group media
rm -rf /srv/media-store
ensure_user media
old=1501
while getent passwd "$old" >/dev/null || getent group "$old" >/dev/null; do old=$((old + 1)); done
mkdir -p /srv/media-store/cache /srv/media-store/originals
for i in 1 2 3; do head -c 1M /dev/urandom > "/srv/media-store/originals/photo-$i.jpg"; done
chown -R "$old:$old" /srv/media-store
chmod -R u=rwX,g=rX,o= /srv/media-store
id -u media > "$TASK_VAR/uid"

write_unit media-api <<EOF
[Unit]
Description=Media API
After=network.target

[Service]
User=media
Environment=NAME=media-api PORT=8060 DATA_DIR=/srv/media-store/cache
ExecStart=/usr/bin/python3 $WEBAPP
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now media-api >/dev/null 2>&1
wait_for_port 8060
