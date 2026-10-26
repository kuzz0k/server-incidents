#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-40
. "$(dirname "$0")/../../../lib/check.sh"

S=/usr/local/bin/disk-alert.sh
MP=/mnt/trainer-alert
TMPMP=/mnt/trainer-tmpfs

setup_fixture() {
  umount -l "$MP" "$TMPMP" 2>/dev/null
  local dev; dev=$(make_disk linux40 60) || return 1
  mkfs.ext4 -q -F "$dev" && mkdir -p "$MP" "$TMPMP" && mount "$dev" "$MP" || return 1
  while (( $(df --output=pcent "$MP" | tail -1 | tr -dc 0-9) < 90 )); do
    head -c 2M /dev/zero >> "$MP/fill.bin" 2>/dev/null || break
  done
  mount -t tmpfs -o size=1M tmpfs "$TMPMP" && head -c 2M /dev/zero > "$TMPMP/fill.bin" 2>/dev/null
  return 0
}
cleanup() { umount -l "$MP" "$TMPMP" 2>/dev/null; remove_disk linux40; }
trap cleanup EXIT

run_and_log() {  # run_and_log <args> → печатает журнал disk-alert за время запуска
  local since; since=$(date '+%Y-%m-%d %H:%M:%S'); sleep 1
  "$S" "$@" >/dev/null 2>&1; echo $? > "$TASK_VAR/rc"
  sleep 1
  journalctl -t disk-alert --since "$since" --no-pager -q -o cat
}

check "скрипт существует и исполняемый" test -x "$S"
check "тестовые ФС подготовлены" setup_fixture
LOG85=$(run_and_log 85); RC85=$(cat "$TASK_VAR/rc")
LOG95=$(run_and_log 95)
LOGDEF=$(run_and_log)
check "порог 85: код возврата 1" test "$RC85" -eq 1
check "порог 85: алерт про $MP в журнале" grep -q "$MP" <<<"$LOG85"
check "порог 85: в алерте есть процент" grep -Eq "$MP.*[0-9]+ ?%|[0-9]+ ?%.*$MP" <<<"$LOG85"
no_tmpfs_alert() { ! grep -q "$TMPMP" <<<"$LOG85"; }
no_alert_95() { ! grep -q "$MP" <<<"$LOG95"; }
check "tmpfs игнорируется" no_tmpfs_alert
check "порог 95: про $MP алерта нет" no_alert_95
check "без аргумента порог 85" grep -q "$MP" <<<"$LOGDEF"
check "есть расписание запуска" bash -c "grep -rqs disk-alert /etc/cron.d /etc/crontab /var/spool/cron/crontabs /etc/systemd/system/*.timer /etc/systemd/system/*.service"
finish
