#!/usr/bin/env bash
set -uo pipefail
TASK_ID=docker-05
. "$(dirname "$0")/../../../lib/check.sh"

APP=/opt/trainer-docker/reports-api
IMG=trainer/reports-api:2.0

build() { (cd "$APP" && timeout 900 docker build -q -t "$IMG" .) >/dev/null 2>&1; }
size_ok() { (( $(docker image inspect -f '{{.Size}}' "$IMG") < 200 * 1000 * 1000 )); }
non_root() {
  local u; u=$(docker image inspect -f '{{.Config.User}}' "$IMG" 2>/dev/null) || return 1
  [[ -n $u && ! $u =~ ^(root|0)(:|$) ]]
}
no_test_data() { [[ -z $(docker run --rm --entrypoint find "$IMG" / -xdev -name 'dump-*.sql' 2>/dev/null) ]]; }
deps_before_code() {
  local f=$APP/Dockerfile pip code
  pip=$(grep -nE '^\s*RUN .*pip' "$f" | head -1 | cut -d: -f1)
  code=$(grep -nE '^\s*COPY .*(app\.py|\s\.\s)' "$f" | grep -v requirements | head -1 | cut -d: -f1)
  [[ -n $pip && -n $code ]] && (( pip < code ))
}
imports_requests() { docker run --rm --entrypoint python3 "$IMG" -c 'import requests'; }
serves() {
  docker rm -f reports-api-check >/dev/null 2>&1
  docker run -d --name reports-api-check -p 8205:8000 "$IMG" >/dev/null || return 1
  wait_until 15 http_ok http://127.0.0.1:8205/health
  local rc=$?
  docker rm -f reports-api-check >/dev/null 2>&1
  return $rc
}

echo "  Собираю $IMG (может занять несколько минут)…"
check "образ собирается" build
check "образ меньше 200 МБ ($(( $(docker image inspect -f '{{.Size}}' "$IMG" 2>/dev/null || echo 0) / 1000000 )) МБ)" size_ok
check "процесс работает не от root" non_root
check "test-data не попал в образ" no_test_data
check "зависимости ставятся до копирования кода" deps_before_code
check "модуль requests доступен" imports_requests
check_sh "test-data/ на месте в каталоге проекта" "ls $APP/test-data/dump-1.sql"
check "контейнер отвечает на /health" serves
finish
