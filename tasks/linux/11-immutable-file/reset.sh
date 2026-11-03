#!/usr/bin/env bash
# linux-11: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-11
. "$(dirname "$0")/../../../lib/common.sh"

for f in /etc/payment/config.yml /var/log/payment/audit.log; do
  [[ -e $f ]] && chattr -ia "$f" 2>/dev/null
done
rm -rf /etc/payment /var/log/payment /opt/payment
exit 0
