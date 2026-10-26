#!/usr/bin/env bash
set -uo pipefail
TASK_ID=nginx-03
. "$(dirname "$0")/../../../lib/check.sh"

check_http "GET / → 200" 200 http://127.0.0.1:8103/
check_body "главная — страница блога" "DevOps blog" http://127.0.0.1:8103/
check_http "GET /images/logo.png → 200" 200 http://127.0.0.1:8103/images/logo.png
check "index.htm на месте" test -f /srv/www/blog/index.htm
check "нет world-writable в /srv/www и /srv/media" bash -c "! find /srv/www /srv/media -perm -o+w | grep -q ."
check "workers nginx работают от www-data" bash -c "ps -o user= -C nginx | grep -qx www-data && ! grep -Eq '^\s*user\s+root' /etc/nginx/nginx.conf"
finish
