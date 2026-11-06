#!/usr/bin/env bash
# linux-56: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-56
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit file-sync
rm -rf /srv/sync-data
restore_original /etc/sysctl.conf
orig_files=" $(recall sysctl-d-files) "
for f in /etc/sysctl.d/*; do
  [[ -f $f && $orig_files != *" $(basename "$f") "* ]] && grep -qE '^\s*fs\.inotify\.max_user_watches' "$f" && rm -f "$f"
done
grep -rlsF '# trainer-linux-56: ' /etc/sysctl.d/ | xargs -r sed -i 's/^# trainer-linux-56: //'
v=$(recall max-watches); [[ -n $v ]] && sysctl -qw fs.inotify.max_user_watches="$v"
exit 0
