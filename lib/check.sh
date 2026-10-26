#!/usr/bin/env bash
# Хелперы для check.sh. Каждая проверка печатает ✓/✗, finish выводит итог и код выхода.

. "$(dirname "${BASH_SOURCE[0]}")/common.sh"

_C_TOTAL=0
_C_FAIL=0

printf '%s\n\n' "${C_BOLD}Проверка ${TASK_ID:-}${C_OFF}"

# check "описание" <команда...> — команда (или функция) должна завершиться с кодом 0
check() {
  local desc=$1; shift
  _C_TOTAL=$((_C_TOTAL + 1))
  if "$@" >/dev/null 2>&1; then
    printf '  %s✓%s %s\n' "$C_GREEN" "$C_OFF" "$desc"
  else
    _C_FAIL=$((_C_FAIL + 1))
    printf '  %s✗%s %s\n' "$C_RED" "$C_OFF" "$desc"
  fi
}

# check_sh "описание" 'строка для bash -c'
check_sh() { check "$1" bash -c "$2"; }

# http_code <url> [curl args] — печатает HTTP-код (000, если не ответили)
http_code() { curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$@" || true; }

_http_is() { local code=$1; shift; [[ $(http_code "$@") == "$code" ]]; }
_http_body_has() { local text=$1; shift; curl -fsS --max-time 5 "$@" | grep -qF -- "$text"; }

# check_http "описание" <код> <url> [curl args]
check_http() { local d=$1 c=$2; shift 2; check "$d" _http_is "$c" "$@"; }

# check_body "описание" <подстрока> <url> [curl args]
check_body() { local d=$1 t=$2; shift 2; check "$d" _http_body_has "$t" "$@"; }

# service_stable <unit> [секунды] — активен и не перезапускался всё это время
service_stable() {
  local u=$1 s=${2:-5} r1 p1
  systemctl is-active -q "$u" || return 1
  r1=$(systemctl show -p NRestarts --value "$u")
  p1=$(systemctl show -p MainPID --value "$u")
  sleep "$s"
  systemctl is-active -q "$u" || return 1
  [[ $(systemctl show -p NRestarts --value "$u") == "$r1" && $(systemctl show -p MainPID --value "$u") == "$p1" ]]
}

# answer_is <key> <ожидаемое> — сравнение без учёта регистра и пробелов по краям
answer_is() {
  local got
  got=$(answer_get "$1") || return 1
  [[ ${got,,} == "${2,,}" ]]
}

finish() {
  echo
  if ((_C_FAIL == 0)); then
    printf '%s\n' "${C_GREEN}${C_BOLD}PASS${C_OFF} — пройдены все проверки ($_C_TOTAL)"
    exit 0
  fi
  printf '%s\n' "${C_RED}${C_BOLD}FAIL${C_OFF} — не пройдено $_C_FAIL из $_C_TOTAL"
  exit 1
}
