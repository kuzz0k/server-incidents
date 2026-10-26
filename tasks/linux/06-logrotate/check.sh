#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-06
. "$(dirname "$0")/../../../lib/check.sh"

DIR=/var/log/billing
STATE=$TASK_VAR/logrotate.state

dry_run_clean() { ! logrotate -d -s "$STATE" /etc/logrotate.d/billing 2>&1 | grep -qi 'error'; }
force_rotate() {
  rm -f "$DIR"/billing.log.1*
  logrotate -f -s "$STATE" /etc/logrotate.d/billing && ls "$DIR"/billing.log.1* >/dev/null
}
app_writes_new_log() { sleep 3; [[ -s $DIR/billing.log ]] && (( $(stat -c %s "$DIR/billing.log") < 1000000 )); }

check "logrotate -d без ошибок" dry_run_clean
check "logrotate -f создаёт billing.log.1*" force_rotate
check "billing-app пишет в новый billing.log" app_writes_new_log
check "права каталога 775 billing:billing" bash -c "[[ \$(stat -c '%a %U:%G' $DIR) == '775 billing:billing' ]]"
finish
