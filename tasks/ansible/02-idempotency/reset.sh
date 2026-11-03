#!/usr/bin/env bash
# ansible-02: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=ansible-02
. "$(dirname "$0")/../../../lib/common.sh"

remove_user appuser
remove_group appusers
rm -rf /opt/app /etc/app /opt/trainer-ansible/base
restore_original /etc/motd
rmdir_empty /opt/trainer-ansible
exit 0
