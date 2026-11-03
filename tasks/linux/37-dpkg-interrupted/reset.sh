#!/usr/bin/env bash
# linux-37: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-37
. "$(dirname "$0")/../../../lib/common.sh"

systemctl disable --now checkout-agent >/dev/null 2>&1
if dpkg-query -W checkout-agent >/dev/null 2>&1; then
  dpkg --purge checkout-agent >/dev/null 2>&1 || dpkg --purge --force-all checkout-agent >/dev/null 2>&1
fi
systemctl daemon-reload
remove_user checkout
remove_group checkout
rm -rf /etc/checkout-agent /var/cache/trainer/checkout-agent_1.0.0_all.deb
rmdir_empty /var/cache/trainer
exit 0
