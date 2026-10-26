#!/usr/bin/env bash
set -euo pipefail
TASK_ID=git-03
. "$(dirname "$0")/../../../lib/common.sh"

R=/srv/git/webapp
rm -rf "$R"
mkdir -p "$R/config"
cd "$R"
git init -q -b main
git config user.name "Web Team"
git config user.email web@example.com
ts=$(date -d '-10 days' +%s)
commit() { ts=$((ts + 7200)); GIT_AUTHOR_DATE="@$ts" GIT_COMMITTER_DATE="@$ts" git -c "user.name=$1" commit -q -am "$2"; }

cat > config/app.ini <<'EOF'
[server]
port = 8080
timeout = 30
workers = 4
EOF
cat > app.py <<'EOF'
import configparser

CFG = configparser.ConfigParser()
CFG.read("config/app.ini")


def handle(path):
    return f"200 {path}"
EOF
cat > run-tests.sh <<'EOF'
#!/bin/bash
# Тесты итогового состояния после слияния rate-limit
cd "$(dirname "$0")"
export PYTHONDONTWRITEBYTECODE=1
python3 - <<'PY'
from app import CFG, handle_request, limited_handle
assert CFG.getint("server", "timeout") == 60, "timeout must be 60"
assert CFG.getint("server", "rate_limit") == 100, "rate_limit must be 100"
assert CFG.getint("server", "workers") == 4
assert handle_request("/") == "200 /"
assert limited_handle("/", 1) == "200 /"
assert limited_handle("/", 101).startswith("429")
print("tests passed")
PY
EOF
chmod +x run-tests.sh
printf '__pycache__/\n' > .gitignore
git add -A
commit "Web Team" "initial webapp"

git switch -q -c feature/rate-limit
sed -i 's/^timeout = 30$/timeout = 30\nrate_limit = 100/' config/app.ini
cat >> app.py <<'EOF'


def limited_handle(path, count):
    limit = CFG.getint("server", "rate_limit")
    if count > limit:
        return "429 Too Many Requests"
    return handle(path)
EOF
commit "Anna Petrova" "add rate limiting"
echo "# rate limit: requests per client per minute" > config/README
git add config/README
commit "Anna Petrova" "document rate limit"

git switch -q main
sed -i 's/^timeout = 30$/timeout = 60/' config/app.ini
commit "Ivan Sidorov" "increase timeout to 60s"
sed -i 's/^def handle(path):$/def handle_request(path):/' app.py
commit "Ivan Sidorov" "rename handle to handle_request"

git rev-parse main > "$TASK_VAR/main"
git rev-parse feature/rate-limit > "$TASK_VAR/feature"
