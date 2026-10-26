#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-04
. "$(dirname "$0")/../../../lib/check.sh"

fstab_lines() { awk -v mp="$1" '$1 !~ /^#/ && $2 == mp' /etc/fstab; }
entry_ok() {
  local lines
  lines=$(fstab_lines "$1")
  [[ $(grep -c . <<<"$lines") -eq 1 ]] || return 1
  awk '{print $1}' <<<"$lines" | grep -Eq '^(UUID|LABEL)=' || return 1
  awk '{print $4}' <<<"$lines" | tr ',' '\n' | grep -qx nofail
}
mounts_right_disk() {
  local mp=$1 name=$2
  if mountpoint -q "$mp"; then umount "$mp" || return 1; fi
  mount "$mp" || return 1
  [[ $(cat "$mp/.disk-id") == "disk=$name" ]]
}

systemctl daemon-reload
check "/data: одна запись в fstab, по UUID/LABEL, с nofail" entry_ok /data
check "/backup: одна запись в fstab, по UUID/LABEL, с nofail" entry_ok /backup
check "mount /data монтирует диск data" mounts_right_disk /data data
check "mount /backup монтирует диск backup" mounts_right_disk /backup backup
finish
