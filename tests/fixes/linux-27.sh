#!/usr/bin/env bash
# Эталонное решение linux-27 (для tests/selftest.sh)
set -euo pipefail
. "$(dirname "$0")/../../lib/common.sh"
timedatectl set-timezone Etc/UTC
if [[ -f $TRAINER_VAR/tasks/linux-27/had-chrony ]]; then
  systemctl enable --now chrony
  chronyc makestep >/dev/null || true
else
  timedatectl set-ntp true
  systemctl restart systemd-timesyncd
fi
wait_until 60 bash -c '[[ $(timedatectl show -p NTPSynchronized --value) == yes ]]' || true
