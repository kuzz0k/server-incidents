#!/usr/bin/env bash
# linux-08: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-08
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit webhook
rm -f /etc/sudoers.d/deploy.conf /etc/sudoers.d/deploy /etc/sudoers.d/zz-deploy /etc/sudoers.d/ops-admins
# правило могли положить под другим именем
grep -lsE 'restart webhook|^%ops[[:space:]]' /etc/sudoers.d/* | xargs -r rm -f
[[ $(recall deploy-existed) == no ]] && remove_user deploy
[[ $(recall ops-existed) == no ]] && remove_group ops
visudo -cq || warn "visudo -c сообщает об ошибке в sudoers — проверь /etc/sudoers.d"
exit 0
