#!/usr/bin/env bash
# linux-27: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-27
. "$(dirname "$0")/../../../lib/common.sh"

tz=$(recall timezone)
[[ -n $tz ]] && timedatectl set-timezone "$tz"
if [[ -f $TASK_VAR/had-chrony ]]; then
  systemctl enable --now chrony >/dev/null 2>&1
  chronyc makestep >/dev/null 2>&1
elif [[ $(recall ntp) == yes ]]; then
  timedatectl set-ntp true 2>/dev/null
  systemctl restart systemd-timesyncd 2>/dev/null
  wait_until 60 bash -c '[[ $(timedatectl show -p NTPSynchronized --value) == yes ]]' \
    || warn "NTP ещё не синхронизировал часы — проверь timedatectl через минуту"
elif [[ $(timedatectl show -p NTP --value) != yes ]]; then
  # NTP не было и до задачи — возвращаем 3 дня, которые отнял break.sh
  date -s "@$(( $(date +%s) + 3 * 86400 ))" >/dev/null
fi
exit 0
