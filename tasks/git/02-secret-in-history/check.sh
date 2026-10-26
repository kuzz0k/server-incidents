#!/usr/bin/env bash
set -uo pipefail
TASK_ID=git-02
. "$(dirname "$0")/../../../lib/check.sh"

L=/srv/git/shop
REM=/srv/git/shop-remote.git
S=TRAINER-FAKE-SECRET
clean() { ! git -C "$1" log --all --reflog -p 2>/dev/null | grep -q "$S"; }
same_file() { [[ $(git -C "$L" show "HEAD:$1" 2>/dev/null | sha256sum) == "$(cat "$TASK_VAR/$2")" ]]; }
in_sync() { [[ -n $(git -C "$REM" rev-parse main 2>/dev/null) && $(git -C "$L" rev-parse main) == "$(git -C "$REM" rev-parse main)" ]]; }

check "секрета нет в истории локального репозитория" clean "$L"
check "секрета нет в истории origin" clean "$REM"
check "config/prod.env игнорируется" git -C "$L" check-ignore -q config/prod.env
check ".gitignore есть в origin/main" git -C "$REM" cat-file -e main:.gitignore
check "app.py на HEAD не изменился" same_file app.py app.sha256
check "config/dev.env на HEAD не изменился" same_file config/dev.env dev.sha256
check "локальный main совпадает с origin/main" in_sync
finish
