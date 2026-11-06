#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-59
. "$(dirname "$0")/../../../lib/check.sh"

U=cache-warmer
unit_ok() { [[ $(answer_get unit) =~ ^cache-warmer(\.service)?$ ]]; }
max_ok() { local m; m=$(systemctl show -p MemoryMax --value "$U"); [[ $m =~ ^[0-9]+$ ]] && (( m <= 300 * 1024 * 1024 )); }
restart_ok() { [[ $(systemctl show -p Restart --value "$U") =~ ^(on-failure|always|on-abnormal)$ ]]; }
current_ok() { local c; c=$(systemctl show -p MemoryCurrent --value "$U"); [[ $c == '[not set]' || $c =~ ^[0-9]+$ && $c -le $((300 * 1024 * 1024)) ]]; }

check "в ответе правильный юнит" unit_ok
check "MemoryMax ≤ 300M" max_ok
check "Restart=on-failure или always" restart_ok
check "сейчас сервис занимает ≤ 300 МБ" current_ok
check "юнит включён (не остановлен насовсем)" systemctl is-enabled -q "$U"
check "search-indexer не тронут" bash -c "systemctl is-active -q search-indexer && [[ \$(systemctl show -p MemoryMax --value search-indexer) == infinity ]]"
finish
