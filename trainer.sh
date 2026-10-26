#!/usr/bin/env bash
# DevOps-тренажёр: ломает Ubuntu-VM и проверяет, как ты её починил.
set -euo pipefail

. "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

usage() {
  cat <<EOF
Использование: sudo ./trainer.sh <команда> [аргументы]

  setup [--all]     поставить базовые пакеты и инструменты диагностики
                    (--all: сразу docker, postgres, mariadb, nginx, ansible,
                     terraform, prometheus, k3s и helm)
  list [тема]       список задач: linux, nginx, postgres, mysql, docker, k8s,
                    ansible, terraform, monitoring, git
  start <id>        подготовить задачу (сломать) и показать описание
  show <id>         показать описание задачи ещё раз
  check <id>        проверить решение
  theory <id>       теория по теме задачи (вопросы с ответами из theory/interview.md)
  solution <id>     показать разбор (шаги, доп. вопросы)

Пример: sudo ./trainer.sh start linux-01
EOF
}

# Все task.env в порядке тем: сначала Linux
task_envs() {
  local t
  for t in $TRAINER_TOPICS; do ls "$TRAINER_ROOT"/tasks/"$t"/*/task.env 2>/dev/null; done
}

# linux-01 → tasks/linux/01-*
task_dir() {
  local id=$1 topic num d
  [[ $id =~ ^([a-z0-9]+)-([0-9]{2})$ ]] || die "Неверный ID задачи: $id (пример: linux-01)"
  topic=${BASH_REMATCH[1]} num=${BASH_REMATCH[2]}
  for d in "$TRAINER_ROOT/tasks/$topic/$num"-*/; do
    [[ -f $d/task.env ]] && { echo "${d%/}"; return 0; }
  done
  die "Задача $id не найдена. Список: ./trainer.sh list"
}

load_task() {
  TDIR=$(task_dir "$1")
  ID='' TITLE='' LEVEL='' TOPIC='' REQUIRES='' TIME_MIN='' NOTES=''
  # shellcheck disable=SC1091
  . "$TDIR/task.env"
}

# Статус одним символом: так колонки не разъезжаются из-за кириллицы
status_of() {
  if [[ -f $STATE_DIR/$1.solved ]]; then echo "${C_GREEN}✓${C_OFF}"
  elif [[ -f $STATE_DIR/$1.started ]]; then echo "${C_YELLOW}…${C_OFF}"
  else echo "${C_DIM}·${C_OFF}"
  fi
}

cmd_list() {
  local filter=${1:-} env total=0 solved=0
  printf '%s\n' "${C_BOLD}   ID           уровень  мин  задача${C_OFF}"
  for env in $(task_envs); do
    ID='' TITLE='' LEVEL='' TOPIC='' TIME_MIN=''
    # shellcheck disable=SC1090
    . "$env"
    [[ -z $filter || $TOPIC == "$filter" ]] || continue
    total=$((total + 1))
    [[ -f $STATE_DIR/$ID.solved ]] && solved=$((solved + 1))
    printf ' %s %-12s %-8s %-4s %s\n' "$(status_of "$ID")" "$ID" "$LEVEL" "$TIME_MIN" "$TITLE"
  done
  printf '\nРешено %s из %s   (✓ решено, … в работе, · не начато)\n' "$solved" "$total"
}

cmd_show() {
  load_task "$1"
  echo
  cat "$TDIR/README.md"
  echo
  printf '%s\n' "${C_DIM}Ответы для задач-расследований — в /root/answers/$ID.txt. Проверка: sudo ./trainer.sh check $ID${C_OFF}"
}

open_tasks() {
  local f id
  for f in "$STATE_DIR"/*.started; do
    [[ -e $f ]] || continue
    id=$(basename "$f" .started)
    [[ -f $STATE_DIR/$id.solved || $id == "$1" ]] || echo "$id"
  done
}

cmd_start() {
  load_task "$1"
  require_ubuntu
  mkdir -p "$STATE_DIR" "$ANSWERS_DIR"
  local open
  open=$(open_tasks "$ID" | tr '\n' ' ')
  if [[ -n $open && -z ${TRAINER_YES:-} ]]; then
    warn "Есть начатые и не решённые задачи: $open"
    warn "Они могут мешать друг другу (особенно linux-21/27/28 ломают apt и DNS)."
    read -r -p "Продолжить? [y/N] " ans
    [[ $ans == [yYдД]* ]] || exit 1
  fi
  [[ -n $NOTES ]] && warn "$NOTES"
  ensure_base
  local r
  for r in $REQUIRES; do
    declare -F "ensure_$r" >/dev/null || die "Неизвестная зависимость $r в $TDIR/task.env"
    "ensure_$r"
  done
  info "Готовлю задачу $ID…"
  rm -f "$STATE_DIR/$ID.solved" "$ANSWERS_DIR/$ID.txt"
  bash "$TDIR/break.sh"
  date -Is > "$STATE_DIR/$ID.started"
  info "Задача $ID готова."
  cmd_show "$ID"
}

cmd_check() {
  load_task "$1"
  mkdir -p "$STATE_DIR"
  [[ -f $STATE_DIR/$ID.started ]] || warn "Задача $ID ещё не запускалась (sudo ./trainer.sh start $ID)"
  if bash "$TDIR/check.sh"; then
    date -Is > "$STATE_DIR/$ID.solved"
  else
    return 1
  fi
}

cmd_theory() {
  load_task "$1"
  [[ -f $TDIR/THEORY.md ]] || die "Для $ID нет THEORY.md — собери: python3 theory/build.py"
  echo
  cat "$TDIR/THEORY.md"
}

cmd_solution() {
  load_task "$1"
  if [[ -z ${TRAINER_YES:-} && ! -f $STATE_DIR/$ID.solved ]]; then
    read -r -p "Задача ещё не решена. Точно открыть разбор? [y/N] " ans
    [[ $ans == [yYдД]* ]] || exit 0
  fi
  echo
  cat "$TDIR/SOLUTION.md"
}

cmd_setup() {
  require_ubuntu
  ensure_base
  ensure_diag_tools
  if [[ ${1:-} == --all ]]; then
    ensure_docker
    ensure_postgres
    ensure_nginx
    ensure_mysql
    ensure_ansible
    ensure_terraform
    ensure_prometheus
    ensure_k3s
    ensure_helm
  fi
  mkdir -p "$STATE_DIR" "$ANSWERS_DIR"
  install_webapp
  info "Готово. Список задач: sudo ./trainer.sh list"
}

main() {
  local cmd=${1:-}
  [[ -n $cmd ]] || { usage; exit 1; }
  shift
  case $cmd in
    -h|--help|help) usage; return ;;
  esac
  require_root
  case $cmd in
    setup)    cmd_setup "$@" ;;
    list)     cmd_list "$@" ;;
    start)    [[ $# -ge 1 ]] || die "Укажи ID задачи"; cmd_start "$1" ;;
    show)     [[ $# -ge 1 ]] || die "Укажи ID задачи"; cmd_show "$1" ;;
    check)    [[ $# -ge 1 ]] || die "Укажи ID задачи"; cmd_check "$1" ;;
    theory)   [[ $# -ge 1 ]] || die "Укажи ID задачи"; cmd_theory "$1" ;;
    solution) [[ $# -ge 1 ]] || die "Укажи ID задачи"; cmd_solution "$1" ;;
    *) usage; exit 1 ;;
  esac
}

main "$@"
