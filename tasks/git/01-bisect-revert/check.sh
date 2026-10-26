#!/usr/bin/env bash
set -uo pipefail
TASK_ID=git-01
. "$(dirname "$0")/../../../lib/check.sh"

R=/srv/git/billing
bad=$(cat "$TASK_VAR/bad" 2>/dev/null)
orig=$(cat "$TASK_VAR/orig" 2>/dev/null)
answer_ok() { local a; a=$(answer_get bad_commit) || return 1; [[ ${#a} -ge 7 && $bad == "${a,,}"* ]]; }

check "на ветке main" bash -c "[[ \$(git -C $R rev-parse --abbrev-ref HEAD) == main ]]"
check "рабочая копия чистая" bash -c "[[ -z \$(git -C $R status --porcelain) ]]"
check "./run-tests.sh проходит" "$R/run-tests.sh"
check "история не переписана (старый HEAD — предок нового)" git -C "$R" merge-base --is-ancestor "$orig" HEAD
check "в ответе хэш плохого коммита" answer_ok
finish
