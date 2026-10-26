#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-31
. "$(dirname "$0")/../../../lib/check.sh"

S=/opt/deploy/deploy.sh
REL="/opt/deploy/release store"
work=$(mktemp -d)

reset_state() {
  rm -rf "$REL/1.2.3" /opt/deploy/release/ 2>/dev/null
  mkdir -p "$REL"
  [[ -d $REL/1.2.2 ]] || cp -a "$TASK_VAR/release-1.2.2" "$REL/1.2.2"
  ln -sfn "$REL/1.2.2" /opt/deploy/current
}
deploy_ok() {
  reset_state
  (cd "$work" && "$S" 1.2.3) >/dev/null 2>&1 || return 1
  [[ $(readlink /opt/deploy/current) == "$REL/1.2.3" && $(cat /opt/deploy/current/VERSION) == 1.2.3 ]]
}
no_args() {
  local out rc
  out=$(cd "$work" && "$S" 2>&1); rc=$?
  (( rc == 1 )) && grep -qi usage <<<"$out"
}
missing_version() {
  reset_state
  (cd "$work" && "$S" 9.9.9) >/dev/null 2>&1 && return 1
  [[ $(readlink /opt/deploy/current) == "$REL/1.2.2" ]]
}
no_garbage() { [[ -z $(ls -A "$work") ]]; }

check "в скрипте нет CRLF" bash -c "! grep -q \$'\r' $S"
check "deploy.sh 1.2.3 → exit 0, current → 1.2.3" deploy_ok
check "без аргументов → usage и exit 1" no_args
check "deploy.sh 9.9.9 → ошибка, current не изменён" missing_version
check "в текущем каталоге не появилось мусора" no_garbage
rm -rf "$work"
finish
