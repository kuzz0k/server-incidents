#!/usr/bin/env bash
# Самотест тренажёра. Для каждой задачи:
#   снимок системы → break → check (ждём FAIL) → эталонный фикс → check (ждём PASS)
#   → reset → снимок (должен совпасть с исходным)
#   → break → skip → снимок (тоже должен совпасть; отключается флагом --fast)
# Запускать ТОЛЬКО на одноразовой VM или перед откатом снапшота: задачи по-настоящему ломают систему.
#
#   sudo ./tests/selftest.sh all            # все задачи
#   sudo ./tests/selftest.sh linux nginx    # темы целиком
#   sudo ./tests/selftest.sh linux-01 k8s-03 --fast
set -uo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
. "$ROOT/lib/common.sh"
require_root

[[ $# -ge 1 ]] || { sed -n '2,10p' "$0"; exit 1; }

fast=''
ids=()
for arg in "$@"; do
  [[ $arg == --fast ]] && { fast=1; continue; }
  for env in $(for t in $TRAINER_TOPICS; do ls "$ROOT"/tasks/"$t"/*/task.env 2>/dev/null; done); do
    # shellcheck disable=SC1090
    id=$(. "$env" && echo "$ID") topic=$(. "$env" && echo "$TOPIC")
    [[ $arg == all || $arg == "$topic" || $arg == "$id" ]] && ids+=("$id")
  done
done
((${#ids[@]})) || die "Задачи не найдены: $*"

LOGS=$TRAINER_VAR/selftest
mkdir -p "$LOGS"
passed=() failed=()
T="$ROOT/trainer.sh"
export TRAINER_YES=1

# same_state <файл-до> <имя> — снять снимок и сравнить с исходным, разницу положить рядом с логом
same_state() {
  "$ROOT/tests/state-snapshot.sh" > "$LOGS/$id.$2.state"
  if ! diff -u "$1" "$LOGS/$id.$2.state" > "$LOGS/$id.$2.diff"; then
    cat "$LOGS/$id.$2.diff" >> "$log"
    return 1
  fi
  rm -f "$LOGS/$id.$2.diff"
}

for id in "${ids[@]}"; do
  log=$LOGS/$id.log
  : > "$log"
  printf '%-14s ' "$id"
  start=$(date +%s)
  result=""
  before=$LOGS/$id.before.state
  if ! "$T" deps "$id" >>"$log" 2>&1; then
    result="не поставились зависимости"
  else
    "$ROOT/tests/state-snapshot.sh" > "$before"
    if ! "$T" start "$id" >>"$log" 2>&1; then
      result="start упал"
    elif "$T" check "$id" >>"$log" 2>&1; then
      result="check прошёл сразу после break"
    elif ! bash "$ROOT/tests/fixes/$id.sh" >>"$log" 2>&1; then
      result="эталонный фикс упал"
    elif ! "$T" check "$id" >>"$log" 2>&1; then
      result="check не прошёл после фикса"
    elif ! "$T" reset "$id" >>"$log" 2>&1; then
      result="reset упал"
    elif ! same_state "$before" after-reset; then
      result="после reset система отличается: $LOGS/$id.after-reset.diff"
    elif [[ -z $fast ]]; then
      if ! "$T" start "$id" >>"$log" 2>&1; then
        result="повторный start упал"
      elif ! "$T" skip "$id" >>"$log" 2>&1; then
        result="skip упал"
      elif ! same_state "$before" after-skip; then
        result="после skip система отличается: $LOGS/$id.after-skip.diff"
      fi
    fi
  fi
  took=$(( $(date +%s) - start ))
  if [[ -z $result ]]; then
    passed+=("$id")
    printf '%sOK%s   (%ss)\n' "$C_GREEN" "$C_OFF" "$took"
  else
    failed+=("$id")
    printf '%sFAIL%s %s (%ss), лог: %s\n' "$C_RED" "$C_OFF" "$result" "$took" "$log"
  fi
done

echo
echo "Пройдено: ${#passed[@]}, упало: ${#failed[@]}"
((${#failed[@]} == 0)) || { echo "Упали: ${failed[*]}"; exit 1; }
