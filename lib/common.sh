#!/usr/bin/env bash
# Общие функции тренажёра. Подключается из trainer.sh, break.sh, check.sh и tests/fixes.
# Перед подключением скрипт задачи может выставить TASK_ID — тогда появится $TASK_VAR.

TRAINER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TRAINER_VAR=/var/lib/devops-trainer
TRAINER_LIB=/usr/local/lib/devops-trainer
STATE_DIR=$TRAINER_VAR/state
ANSWERS_DIR=/root/answers
WEBAPP=$TRAINER_LIB/webapp.py
# Порядок тем в списке задач и самотесте
TRAINER_TOPICS="linux nginx postgres mysql docker k8s ansible terraform monitoring git"
export DEBIAN_FRONTEND=noninteractive
export KUBECONFIG=${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}

if [[ -t 1 ]]; then
  C_RED=$'\e[31m' C_GREEN=$'\e[32m' C_YELLOW=$'\e[33m' C_BLUE=$'\e[34m' C_BOLD=$'\e[1m' C_DIM=$'\e[90m' C_OFF=$'\e[0m'
else
  C_RED='' C_GREEN='' C_YELLOW='' C_BLUE='' C_BOLD='' C_DIM='' C_OFF=''
fi

info() { printf '%s\n' "${C_BLUE}==>${C_OFF} $*"; }
warn() { printf '%s\n' "${C_YELLOW}[!]${C_OFF} $*" >&2; }
die()  { printf '%s\n' "${C_RED}[x]${C_OFF} $*" >&2; exit 1; }

require_root() { [[ $EUID -eq 0 ]] || die "Нужны права root: запусти через sudo"; }

require_ubuntu() {
  local id ver
  id=$(. /etc/os-release && echo "$ID")
  ver=$(. /etc/os-release && echo "$VERSION_ID")
  [[ $id == ubuntu ]] || die "Тренажёр рассчитан на Ubuntu, а здесь $id"
  [[ $ver == 22.04 || $ver == 24.04 ]] || warn "Проверено на Ubuntu 22.04/24.04, здесь $ver — что-то может отличаться"
}

if [[ -n ${TASK_ID:-} ]]; then
  TASK_VAR=$TRAINER_VAR/tasks/$TASK_ID
  mkdir -p "$TASK_VAR"
fi

# --- пакеты ---------------------------------------------------------------

pkg_installed() { dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q 'install ok installed'; }

ensure_pkgs() {
  local p missing=()
  for p in "$@"; do pkg_installed "$p" || missing+=("$p"); done
  ((${#missing[@]} == 0)) && return 0
  info "Устанавливаю пакеты: ${missing[*]}"
  apt-get update -qq >/dev/null 2>&1 || warn "apt-get update завершился с ошибкой"
  apt-get install -y -qq "${missing[@]}" >/dev/null \
    || die "Не удалось установить ${missing[*]}. Проверь apt/DNS/время (не осталась ли нерешённой linux-21, linux-27 или linux-28?)"
}

# --- ожидание -------------------------------------------------------------

# wait_until <секунды> <команда...> — повторяет команду раз в секунду
wait_until() {
  local t=$1 i; shift
  for ((i = 0; i < t; i++)); do
    "$@" >/dev/null 2>&1 && return 0
    sleep 1
  done
  return 1
}

port_listening() { ss -Hltn "sport = :$1" | grep -q .; }
http_ok() { curl -fsS -o /dev/null --max-time 3 "$@"; }
wait_for_port() { wait_until "${2:-15}" port_listening "$1"; }
wait_for_http() { wait_until "${2:-15}" http_ok "$1"; }

primary_ip() { ip -4 route get 1.1.1.1 2>/dev/null | awk '{for (i = 1; i < NF; i++) if ($i == "src") { print $(i + 1); exit }}'; }

# --- systemd и демо-приложение ---------------------------------------------

install_webapp() { install -D -m 0755 "$TRAINER_ROOT/lib/apps/webapp.py" "$WEBAPP"; }

_unit_name() { [[ $1 == *.* ]] && echo "$1" || echo "$1.service"; }

# remove_unit <unit...> — остановить, выключить и удалить юнит вместе с drop-in'ами
remove_unit() {
  local u
  for u in "$@"; do
    u=$(_unit_name "$u")
    systemctl disable --now "$u" >/dev/null 2>&1 || true
    systemctl stop "$u" >/dev/null 2>&1 || true
    rm -rf "/etc/systemd/system/$u" "/etc/systemd/system/$u.d"
    systemctl reset-failed "$u" >/dev/null 2>&1 || true
  done
  systemctl daemon-reload
}

# write_unit <unit> — содержимое юнита читается из stdin
write_unit() {
  local u
  u=$(_unit_name "$1")
  cat > "/etc/systemd/system/$u"
  systemctl daemon-reload
}

ensure_user() {
  local name=$1; shift
  id -u "$name" >/dev/null 2>&1 || useradd --system --no-create-home --shell /usr/sbin/nologin "$@" "$name"
}

remove_user() {
  local name
  for name in "$@"; do
    id -u "$name" >/dev/null 2>&1 || continue
    pkill -KILL -u "$name" 2>/dev/null || true
    userdel -r "$name" >/dev/null 2>&1 || userdel "$name" >/dev/null 2>&1 || true
  done
}

# --- fstab ----------------------------------------------------------------

fstab_clear() { sed -i "/^# devops-trainer $1 begin\$/,/^# devops-trainer $1 end\$/d" /etc/fstab; }

fstab_add() {
  local id=$1; shift
  { echo "# devops-trainer $id begin"; printf '%s\n' "$@"; echo "# devops-trainer $id end"; } >> /etc/fstab
  systemctl daemon-reload
}

# hosts_drop <regex> — убрать строки из /etc/hosts без rename (файл может быть bind-mount)
hosts_drop() {
  local tmp
  tmp=$(mktemp)
  grep -Ev -- "$1" /etc/hosts > "$tmp" || true
  cat "$tmp" > /etc/hosts
  rm -f "$tmp"
}

# --- исходное состояние для отката (reset.sh) -------------------------------

_orig_key() { printf '%s' "$1" | tr '/' '_'; }

# save_original <path> — при первой поломке запомнить исходный файл (или то, что его не было).
# Повторный start ничего не перезаписывает: хранится состояние до самой первой поломки.
save_original() {
  local key; key=$(_orig_key "$1")
  [[ -e $TASK_VAR/orig/$key.saved ]] && return 0
  mkdir -p "$TASK_VAR/orig"
  if [[ -e $1 || -L $1 ]]; then cp -a "$1" "$TASK_VAR/orig/$key"; fi
  echo "$1" > "$TASK_VAR/orig/$key.saved"
}

# restore_original <path> — вернуть файл как было до задачи (удалить, если его не было)
restore_original() {
  local key; key=$(_orig_key "$1")
  [[ -e $TASK_VAR/orig/$key.saved ]] || return 0
  rm -rf "$1"
  if [[ -e $TASK_VAR/orig/$key || -L $TASK_VAR/orig/$key ]]; then cp -a "$TASK_VAR/orig/$key" "$1"; fi
}

# remember <key> <value> / recall <key> — запомнить значение до первой поломки
remember() { mkdir -p "$TASK_VAR/orig"; [[ -e $TASK_VAR/orig/$1.val ]] || printf '%s\n' "$2" > "$TASK_VAR/orig/$1.val"; }
recall() { cat "$TASK_VAR/orig/$1.val" 2>/dev/null; }

# --- хелперы для reset.sh -------------------------------------------------------

remove_group() { local g; for g; do getent group "$g" >/dev/null && groupdel "$g" 2>/dev/null; done; return 0; }

# remove_cron_refs <строка> — убрать задания cron (cron.d и crontab root), где встречается строка
remove_cron_refs() {
  grep -lsF -- "$1" /etc/cron.d/* | xargs -r rm -f
  if crontab -l >/dev/null 2>&1; then crontab -l | grep -vF -- "$1" | crontab -; fi
  return 0
}

# nat_drop_port <порт> — удалить все правила таблицы nat с --dport <порт>
nat_drop_port() {
  local rule
  while rule=$(iptables -t nat -S 2>/dev/null | grep -E -- "--dport $1( |$)" | head -1) && [[ -n $rule ]]; do
    eval "iptables -t nat ${rule/-A /-D }" || break
  done
}

# rmdir_empty <каталог…> — удалить каталоги, только если они пусты
rmdir_empty() { local d; for d; do rmdir "$d" 2>/dev/null; done; return 0; }

# --- ответы на задачи-расследования ----------------------------------------

answers_file() { echo "$ANSWERS_DIR/$TASK_ID.txt"; }

# answer_get <key> — значение из /root/answers/<id>.txt (формат key=value)
answer_get() {
  local f
  f=$(answers_file)
  [[ -f $f ]] || return 1
  sed -n "s/^[[:space:]]*$1[[:space:]]*=[[:space:]]*//p" "$f" | tail -1 | sed 's/[[:space:]]*$//'
}

# --- хелперы для задач -------------------------------------------------------

. "$TRAINER_ROOT/lib/disks.sh"
. "$TRAINER_ROOT/lib/prereqs.sh"
