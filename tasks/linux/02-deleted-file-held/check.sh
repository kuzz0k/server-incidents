#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-02
. "$(dirname "$0")/../../../lib/check.sh"

MP=/var/lib/metrics

no_deleted_open() { ! find /proc/[0-9]*/fd -lname "$MP/*(deleted)" 2>/dev/null | grep -q .; }
log_grows() {
  local a b
  [[ -f $MP/agent.log ]] || return 1
  a=$(stat -c %s "$MP/agent.log"); sleep 5; b=$(stat -c %s "$MP/agent.log")
  ((b > a))
}

check "$MP смонтирован" mountpoint -q "$MP"
check "на $MP занято меньше 50%" bash -c "(( \$(df --output=pcent $MP | tail -1 | tr -dc 0-9) < 50 ))"
check "нет открытых удалённых файлов на $MP" no_deleted_open
check "metrics-agent активен" systemctl is-active -q metrics-agent
check "агент дописывает в $MP/agent.log" log_grows
finish
