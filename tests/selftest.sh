#!/usr/bin/env bash
# Самотест тренажёра: для каждой задачи break → check (ждём FAIL) → эталонный фикс → check (ждём PASS).
# Запускать ТОЛЬКО на одноразовой VM или перед откатом снапшота: задачи по-настоящему ломают систему.
#
#   sudo ./tests/selftest.sh all            # все задачи
#   sudo ./tests/selftest.sh linux nginx    # темы целиком
#   sudo ./tests/selftest.sh linux-01 k8s-03
set -uo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
. "$ROOT/lib/common.sh"
require_root

[[ $# -ge 1 ]] || { sed -n '2,8p' "$0"; exit 1; }

ids=()
for arg in "$@"; do
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

for id in "${ids[@]}"; do
  log=$LOGS/$id.log
  : > "$log"
  printf '%-12s ' "$id"
  start=$(date +%s)
  result=""
  if ! TRAINER_YES=1 "$ROOT/trainer.sh" start "$id" >>"$log" 2>&1; then
    result="start упал"
  elif "$ROOT/trainer.sh" check "$id" >>"$log" 2>&1; then
    result="check прошёл сразу после break"
  elif ! bash "$ROOT/tests/fixes/$id.sh" >>"$log" 2>&1; then
    result="эталонный фикс упал"
  elif ! "$ROOT/trainer.sh" check "$id" >>"$log" 2>&1; then
    result="check не прошёл после фикса"
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
