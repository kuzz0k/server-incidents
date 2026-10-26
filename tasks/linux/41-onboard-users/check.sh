#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-41
. "$(dirname "$0")/../../../lib/check.sh"

S=/usr/local/bin/onboard-users.sh
CSV=/srv/onboarding/users.csv
OUT=/root/onboarding/passwords.txt
declare -A UGROUPS=([a.petrova]="team-dev team-ops" [i.sidorov]="team-dev" [o.kim]="team-qa" [m.orlov]="team-dev team-ops team-qa")
declare -A SHELLS=([a.petrova]=/bin/bash [i.sidorov]=/bin/bash [o.kim]=/bin/bash [m.orlov]=/bin/sh)
declare -A NAMES=([a.petrova]="Anna Petrova" [i.sidorov]="Ivan Sidorov" [o.kim]="Olga Kim" [m.orlov]="Max Orlov")

user_ok() {
  local u=$1 g
  id "$u" >/dev/null 2>&1 || return 1
  [[ $(getent passwd "$u" | cut -d: -f7) == "${SHELLS[$u]}" ]] || return 1
  [[ $(getent passwd "$u" | cut -d: -f5 | cut -d, -f1) == "${NAMES[$u]}" ]] || return 1
  [[ -d $(getent passwd "$u" | cut -d: -f6) ]] || return 1
  for g in ${UGROUPS[$u]}; do id -nG "$u" | tr ' ' '\n' | grep -qx "$g" || return 1; done
}
must_change() { [[ $(getent shadow "$1" | cut -d: -f3) == 0 ]]; }
password_matches() {
  local u=$1 pw hash
  pw=$(grep "^$u:" "$OUT" | head -1 | cut -d: -f2-)
  hash=$(getent shadow "$u" | cut -d: -f2)
  [[ -n $pw ]] && python3 -W ignore -c 'import crypt, sys; sys.exit(0 if crypt.crypt(sys.argv[1], sys.argv[2]) == sys.argv[2] else 1)' "$pw" "$hash"
}

rm -f "$OUT"
for u in "${!UGROUPS[@]}"; do id "$u" >/dev/null 2>&1 && userdel -r "$u" >/dev/null 2>&1; done
check "первый запуск завершается успешно" "$S" "$CSV"
first=$(cat "$OUT" 2>/dev/null)
check "повторный запуск завершается успешно" "$S" "$CSV"
for u in a.petrova i.sidorov o.kim m.orlov; do
  check "$u: группы, shell, GECOS, home" user_ok "$u"
  check "$u: смена пароля при первом входе" must_change "$u"
  check "$u: пароль из passwords.txt подходит" password_matches "$u"
done
check "passwords.txt: права 600" bash -c "[[ \$(stat -c %a $OUT) == 600 ]]"
same_after_rerun() { [[ $(grep -c . "$OUT") -eq 4 && $(cat "$OUT") == "$first" ]]; }
check "passwords.txt: по строке на пользователя, повторный запуск не менял" same_after_rerun
finish
