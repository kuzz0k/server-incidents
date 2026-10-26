#!/usr/bin/env bash
# Эталонное решение git-02 (для tests/selftest.sh)
set -euo pipefail
. "$(dirname "$0")/../../lib/common.sh"
ensure_pkgs git-filter-repo
cd /srv/git/shop
git filter-repo --invert-paths --path config/prod.env --force >/dev/null 2>&1
git remote add origin /srv/git/shop-remote.git 2>/dev/null || true
echo 'config/prod.env' >> .gitignore
git add .gitignore
git commit -q -m "ignore prod env"
git push -q --force origin main
git push -q --force --tags origin
