#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-16
. "$(dirname "$0")/../../../lib/check.sh"

# Доля одного ядра, которую процесс потратил за 3 секунды
cpu_low() {
  local pid t1 t2 hz
  pid=$(systemctl show -p MainPID --value thumbnailer)
  [[ $pid != 0 ]] || return 1
  hz=$(getconf CLK_TCK)
  t1=$(awk '{print $14 + $15}' "/proc/$pid/stat")
  sleep 3
  t2=$(awk '{print $14 + $15}' "/proc/$pid/stat")
  (( (t2 - t1) * 100 / (3 * hz) < 20 ))
}

check "thumbnailer активен" systemctl is-active -q thumbnailer
check "thumbnailer ест меньше 20% ядра" cpu_low
check "у thumbnailer нет CPUQuota" bash -c "[[ \$(systemctl show -p CPUQuotaPerSecUSec --value thumbnailer) == infinity ]]"
check "у thumbnailer не понижен приоритет (Nice=0)" bash -c "[[ \$(systemctl show -p Nice --value thumbnailer) == 0 ]]"
finish
