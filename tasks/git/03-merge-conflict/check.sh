#!/usr/bin/env bash
set -uo pipefail
TASK_ID=git-03
. "$(dirname "$0")/../../../lib/check.sh"

R=/srv/git/webapp
no_markers() { ! git -C "$R" grep -nE '^(<<<<<<<|>>>>>>>)' >/dev/null; }

check "на ветке main" bash -c "[[ \$(git -C $R rev-parse --abbrev-ref HEAD) == main ]]"
check "рабочая копия чистая, нет незавершённого merge" bash -c "[[ -z \$(git -C $R status --porcelain) && ! -e $R/.git/MERGE_HEAD ]]"
check "./run-tests.sh проходит" "$R/run-tests.sh"
check "прежний main — предок нового" git -C "$R" merge-base --is-ancestor "$(cat "$TASK_VAR/main")" main
check "коммиты фичи влиты в main" git -C "$R" merge-base --is-ancestor "$(cat "$TASK_VAR/feature")" main
check "нет маркеров конфликта" no_markers
finish
