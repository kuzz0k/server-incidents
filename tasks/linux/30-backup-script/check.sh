#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-30
. "$(dirname "$0")/../../../lib/check.sh"

S=/usr/local/bin/backup-app.sh
DST=/var/backups/app-data
since=$(date '+%Y-%m-%d %H:%M:%S')

rotation() {
  rm -rf "$DST"; mkdir -p "$DST"; echo keep > "$DST/README.keep"
  local i
  for i in 1 2 3 4 5 6 7; do "$S" >/dev/null 2>&1 || return 1; sleep 1.1; done
  [[ $(find "$DST" -maxdepth 1 -name 'app-data-*.tar.gz' | wc -l) -eq 5 ]]
}
newest_valid() {
  local f
  f=$(find "$DST" -maxdepth 1 -name 'app-data-*.tar.gz' | sort | tail -1)
  [[ -n $f ]] && tar -tzf "$f" | grep -q 'invoice 001.pdf'
}
custom_paths() {
  local src="/tmp/trainer src/my data" dst="/tmp/trainer dst"
  rm -rf "/tmp/trainer src" "$dst"; mkdir -p "$src"; echo x > "$src/file a.txt"
  "$S" "$src" "$dst" >/dev/null 2>&1 || return 1
  local n; n=$(find "$dst" -maxdepth 1 -name 'my data-*.tar.gz' | wc -l)
  rm -rf "/tmp/trainer src" "$dst"
  [[ $n -eq 1 ]]
}
missing_src() {
  local err rc
  err=$("$S" /nonexistent/trainer-src /tmp/trainer-dst-missing 2>&1 >/dev/null); rc=$?
  rm -rf /tmp/trainer-dst-missing
  (( rc != 0 )) && [[ -n $err ]]
}
keep_env() {
  rm -rf "$DST"; local i
  for i in 1 2 3 4; do KEEP=2 "$S" >/dev/null 2>&1 || return 1; sleep 1.1; done
  [[ $(find "$DST" -maxdepth 1 -name 'app-data-*.tar.gz' | wc -l) -eq 2 ]]
}

check "скрипт существует и исполняемый" test -x "$S"
check "после 7 запусков осталось 5 архивов" rotation
check "чужой файл в DST не удалён" test -f "$DST/README.keep"
check "свежий архив валиден и содержит файлы с пробелами" newest_valid
check "пути с пробелами в SRC и DST" custom_paths
check "без SRC: ненулевой код и сообщение в stderr" missing_src
check "KEEP=2 оставляет 2 архива" keep_env
check "в журнале есть записи backup-app" bash -c "journalctl -t backup-app --since '$since' --no-pager -q | grep -q ."
finish
