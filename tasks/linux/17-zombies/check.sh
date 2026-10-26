#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-17
. "$(dirname "$0")/../../../lib/check.sh"

parent=$(cat "$TASK_VAR/parent.pid" 2>/dev/null)
no_zombies() { ! ps -eo stat=,comm= | awk '$1 ~ /^Z/ && $2 == "batch-worker"' | grep -q .; }

check "в ответе правильный parent_pid" answer_is parent_pid "$parent"
check "родительский процесс завершён" bash -c "! kill -0 $parent"
check "зомби batch-worker не осталось" no_zombies
finish
