#!/usr/bin/env bash
set -euo pipefail
TASK_ID=git-02
. "$(dirname "$0")/../../../lib/common.sh"

L=/srv/git/shop
REM=/srv/git/shop-remote.git
rm -rf "$L" "$REM"
mkdir -p /srv/git
git init -q --bare -b main "$REM"
git init -q -b main "$L"
cd "$L"
git config user.name "Shop Team"
git config user.email shop@example.com
git remote add origin "$REM"

ts=$(date -d '-30 days' +%s)
commit() { ts=$((ts + 86400)); GIT_AUTHOR_DATE="@$ts" GIT_COMMITTER_DATE="@$ts" git commit -q -m "$1"; }

printf 'print("shop v1")\n' > app.py
echo "# Shop" > README.md
git add -A; commit "initial shop"
mkdir -p config
printf 'DB_HOST=localhost\nPAYMENT_API_URL=https://sandbox.pay.example\n' > config/dev.env
git add -A; commit "add dev config"
printf 'print("shop v2")\n' > app.py; git add -A; commit "app: v2"
echo "## Run" >> README.md; git add -A; commit "docs: how to run"
printf 'print("shop v3")\n' > app.py; git add -A; commit "app: v3"
printf 'DB_HOST=db.prod.internal\nPAYMENT_API_URL=https://pay.example\nPAYMENT_API_SECRET=TRAINER-FAKE-SECRET-7f3a9c\n' > config/prod.env
git add -A; commit "add prod config"
printf 'print("shop v4")\n' > app.py; git add -A; commit "app: v4"
git rm -q config/prod.env; commit "remove prod config"
echo "## Deploy" >> README.md; git add -A; commit "docs: deploy"
printf 'print("shop v5")\n' > app.py; git add -A; commit "app: v5"
git tag v1.0
git push -q origin main --tags

git show HEAD:app.py | sha256sum > "$TASK_VAR/app.sha256"
git show HEAD:config/dev.env | sha256sum > "$TASK_VAR/dev.sha256"
