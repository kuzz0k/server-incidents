#!/usr/bin/env bash
# linux-41: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-41
. "$(dirname "$0")/../../../lib/common.sh"

remove_user a.petrova i.sidorov o.kim m.orlov
remove_group team-dev team-qa team-ops
restore_original /usr/local/bin/onboard-users.sh
rm -rf /srv/onboarding /root/onboarding
exit 0
