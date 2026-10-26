#!/usr/bin/env bash
# Установка зависимостей задач. Имена функций ensure_<x> соответствуют REQUIRES в task.env.

ensure_base() {
  ensure_pkgs python3 curl iproute2 iptables lvm2 acl e2fsprogs cron logrotate \
    openssh-client openssh-server sudo git psmisc lsof util-linux
}

# Инструменты для диагностики. jq и tree специально не ставим — их нужно поставить в linux-28.
ensure_diag_tools() {
  ensure_pkgs strace tcpdump dnsutils net-tools sysstat ncdu
}

ensure_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    ensure_pkgs docker.io
  fi
  if ! docker compose version >/dev/null 2>&1; then
    ensure_pkgs docker-compose-v2
  fi
  systemctl enable --now docker >/dev/null 2>&1 || true
  wait_until 30 docker info || die "Docker не запустился: systemctl status docker"
}

# --- PostgreSQL --------------------------------------------------------------

ensure_postgres() {
  ensure_pkgs postgresql
  systemctl enable --now postgresql >/dev/null 2>&1 || true
  pg_wait
}

pg_dir() { ls -d /etc/postgresql/*/main 2>/dev/null | sort -V | tail -1; }
pg_ver() { basename "$(dirname "$(pg_dir)")"; }

pg_wait() { wait_until 30 pg_isready -q || die "PostgreSQL не отвечает: systemctl status postgresql@$(pg_ver)-main"; }

pg_restart() {
  systemctl restart "postgresql@$(pg_ver)-main" 2>/dev/null || systemctl restart postgresql
  pg_wait
}

# psql_su [psql args] — psql от суперпользователя postgres, без лишнего вывода
psql_su() { (cd / && sudo -u postgres psql -X -v ON_ERROR_STOP=1 -qAt "$@"); }

# --- nginx ---------------------------------------------------------------------

ensure_nginx() {
  ensure_pkgs nginx
  # default-сайт занимает 80 порт, который нужен traefik из k3s
  rm -f /etc/nginx/sites-enabled/default
  systemctl enable nginx >/dev/null 2>&1 || true
  if nginx -t >/dev/null 2>&1; then
    systemctl reload-or-restart nginx || true
  else
    warn "Конфиг nginx сейчас невалиден (nginx -t) — возможно, не решена задача nginx-02"
  fi
}

# nginx_site <name> — включает сайт, конфиг читается из stdin
nginx_site() {
  cat > "/etc/nginx/sites-available/$1"
  ln -sfn "/etc/nginx/sites-available/$1" "/etc/nginx/sites-enabled/$1"
}

nginx_remove_site() { rm -f "/etc/nginx/sites-enabled/$1" "/etc/nginx/sites-available/$1"; }

nginx_apply() {
  nginx -t >/dev/null 2>&1 || return 1
  if systemctl is-active -q nginx; then
    systemctl reload nginx
    sleep 1   # reload асинхронный: даём воркерам перечитать конфиг
  else
    systemctl restart nginx
  fi
}

# --- k3s -------------------------------------------------------------------------

ensure_k3s() {
  if ! command -v k3s >/dev/null 2>&1; then
    ensure_pkgs curl
    info "Устанавливаю k3s (1–3 минуты)…"
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh - >/dev/null \
      || die "Не удалось установить k3s"
  fi
  systemctl is-active -q k3s || systemctl start k3s
  wait_until 120 kc get nodes || die "k3s API не отвечает: systemctl status k3s"
  kc wait --for=condition=Ready node --all --timeout=180s >/dev/null || die "Нода k3s не стала Ready"
}

kc() { k3s kubectl "$@"; }

# k8s_namespace <ns> — пересоздаёт namespace задачи с нуля
k8s_namespace() {
  kc delete namespace "$1" --ignore-not-found --wait=true >/dev/null 2>&1 || true
  kc create namespace "$1" >/dev/null
}

# --- helm ------------------------------------------------------------------------

HELM_VERSION=v3.16.2

arch_go() { case $(uname -m) in x86_64) echo amd64 ;; aarch64|arm64) echo arm64 ;; *) die "Неподдерживаемая архитектура $(uname -m)" ;; esac; }

ensure_helm() {
  command -v helm >/dev/null 2>&1 && return 0
  info "Устанавливаю helm $HELM_VERSION…"
  local tmp; tmp=$(mktemp -d)
  curl -fsSL "https://get.helm.sh/helm-$HELM_VERSION-linux-$(arch_go).tar.gz" | tar -xz -C "$tmp" \
    || die "Не удалось скачать helm"
  install -m 0755 "$tmp/linux-$(arch_go)/helm" /usr/local/bin/helm
  rm -rf "$tmp"
}

# --- MariaDB -----------------------------------------------------------------------

ensure_mysql() {
  ensure_pkgs mariadb-server mariadb-client
  systemctl enable --now mariadb >/dev/null 2>&1 || true
  wait_until 30 mysqladmin ping --silent || warn "MariaDB не отвечает (возможно, не решена задача mysql-01)"
}

# --- Ansible -------------------------------------------------------------------------

ensure_ansible() { ensure_pkgs ansible-core python3-apt; }

# --- Terraform -------------------------------------------------------------------------

TERRAFORM_VERSION=1.9.8

ensure_terraform() {
  command -v terraform >/dev/null 2>&1 && return 0
  ensure_pkgs unzip
  info "Устанавливаю terraform $TERRAFORM_VERSION…"
  local tmp; tmp=$(mktemp -d)
  curl -fsSL -o "$tmp/tf.zip" \
    "https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_${TERRAFORM_VERSION}_linux_$(arch_go).zip" \
    || die "Не удалось скачать terraform"
  unzip -q "$tmp/tf.zip" -d "$tmp"
  install -m 0755 "$tmp/terraform" /usr/local/bin/terraform
  rm -rf "$tmp"
}

# --- Prometheus --------------------------------------------------------------------------

ensure_prometheus() {
  ensure_pkgs prometheus prometheus-node-exporter
  systemctl enable --now prometheus-node-exporter >/dev/null 2>&1 || true
}
