#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-27
. "$(dirname "$0")/../../../lib/check.sh"

tz_utc() { [[ $(timedatectl show -p Timezone --value) =~ ^(Etc/)?UTC$ ]]; }
ntp_on() { [[ $(timedatectl show -p NTP --value) == yes ]] || systemctl is-active -q chrony; }
offset_ok() {
  local remote now
  remote=$(curl -sI --max-time 5 http://archive.ubuntu.com/ | tr -d '\r' | sed -n 's/^[Dd]ate: //p')
  [[ -n $remote ]] || return 1
  now=$(date +%s)
  remote=$(date -d "$remote" +%s) || return 1
  (( now - remote < 60 && remote - now < 60 ))
}

check "часовой пояс UTC" tz_utc
check "NTP-синхронизация включена" ntp_on
check "расхождение с реальным временем < 60 с" offset_ok
finish
