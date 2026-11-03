#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-41
. "$(dirname "$0")/../../../lib/common.sh"

save_original /usr/local/bin/onboard-users.sh     # trainer reset вернёт исходный вариант
rm -f /usr/local/bin/onboard-users.sh
remove_user a.petrova i.sidorov o.kim m.orlov
for g in team-dev team-qa team-ops; do getent group "$g" >/dev/null && groupdel "$g"; done
rm -f /root/onboarding/passwords.txt
mkdir -p /srv/onboarding
printf '%s\r\n' \
  "login,full_name,groups,shell" \
  "a.petrova,Anna Petrova,team-dev;team-ops,/bin/bash" \
  "i.sidorov,Ivan Sidorov,team-dev,/bin/bash" \
  "" \
  "o.kim,Olga Kim,team-qa,/usr/bin/fish" \
  "m.orlov,Max Orlov,team-ops;team-dev;team-qa,/bin/sh" > /srv/onboarding/users.csv
