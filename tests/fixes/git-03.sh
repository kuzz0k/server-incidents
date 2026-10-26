#!/usr/bin/env bash
# Эталонное решение git-03 (для tests/selftest.sh)
set -euo pipefail
cd /srv/git/webapp
git switch -q main
git merge feature/rate-limit >/dev/null 2>&1 || true
cat > config/app.ini <<'EOF'
[server]
port = 8080
timeout = 60
rate_limit = 100
workers = 4
EOF
sed -i 's/return handle(path)/return handle_request(path)/' app.py
git add config/app.ini app.py
git commit -q --no-edit
