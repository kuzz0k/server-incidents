#!/usr/bin/env bash
# Эталонное решение git-01 (для tests/selftest.sh)
set -euo pipefail
cd /srv/git/billing
git bisect start main v1.0 >/dev/null
git bisect run ./run-tests.sh >/dev/null 2>&1
bad=$(git rev-parse refs/bisect/bad)
git bisect reset >/dev/null 2>&1
mkdir -p /root/answers
echo "bad_commit=$bad" > /root/answers/git-01.txt
git revert --no-edit "$bad" >/dev/null
