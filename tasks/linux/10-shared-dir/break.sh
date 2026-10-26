#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-10
. "$(dirname "$0")/../../../lib/common.sh"

remove_user dev1 dev2 dev3
getent group devteam >/dev/null && groupdel devteam
groupadd devteam
for u in dev1 dev2 dev3; do useradd --create-home --shell /bin/bash "$u"; done
usermod -aG devteam dev1
usermod -aG devteam dev2

rm -rf /srv/projects
install -d -m 0755 -o root -g root /srv/projects
