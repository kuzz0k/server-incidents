#!/usr/bin/env bash
# linux-26: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-26
. "$(dirname "$0")/../../../lib/common.sh"

swapoff /var/lib/swap/trainer.swap 2>/dev/null
rm -f /var/lib/swap/trainer.swap
rmdir_empty /var/lib/swap
sed -i '\|/var/lib/swap/trainer.swap|d' /etc/fstab
restore_original /etc/sysctl.conf
# файлы в sysctl.d, которых не было до задачи и где задан swappiness, — от решения
orig_files=" $(recall sysctl-d-files) "
for f in /etc/sysctl.d/*; do
  [[ -f $f && $orig_files != *" $(basename "$f") "* ]] && grep -qE '^\s*vm\.swappiness' "$f" && rm -f "$f"
done
grep -rlsF '# trainer-linux-26: ' /etc/sysctl.d/ | xargs -r sed -i 's/^# trainer-linux-26: //'
v=$(recall swappiness); [[ -n $v ]] && sysctl -qw vm.swappiness="$v"
exit 0
