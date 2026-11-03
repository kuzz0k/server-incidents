#!/usr/bin/env bash
# Снимок той части системы, которую трогают задачи. selftest сравнивает снимок
# до задачи и после trainer reset / skip: разница = откат что-то не вернул.
set -uo pipefail
export LC_ALL=C KUBECONFIG=${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}

section() { printf '\n## %s\n' "$1"; }
listing() { local d; for d; do [[ -d $d ]] && find "$d" -mindepth 1 -maxdepth 1 -printf '%p %m %u:%g\n' 2>/dev/null; done | sort; }
content() { local f; for f; do [[ -e $f || -L $f ]] && { echo "### $f"; readlink "$f"; sha256sum "$f" 2>/dev/null; stat -c '%a %U:%G' "$f"; }; done; }

section units
# transient-юниты (поды k3s, scope контейнеров) создаются и исчезают сами — не про задачи
systemctl list-unit-files --no-legend --no-pager 2>/dev/null | awk '$2 != "transient" {print $1, $2}' | grep -v '^session-\|^user@' | sort
section active
systemctl list-units --type=service,timer,socket,mount --state=active --no-legend --plain --no-pager 2>/dev/null \
  | awk '{print $1}' | grep -vE '^(session-|user@|run-|docker-|containerd-|var-lib-(docker|kubelet|rancher)|.*k3s.*\.mount)' \
  | grep -vE '^systemd-(timedated|hostnamed|localed|logind)\.service$|^ssh\.service$|containerd-tmpmounts' | sort

section users
getent passwd | cut -d: -f1,6,7 | sort
section groups
getent group | cut -d: -f1,4 | sort

section mounts
findmnt -rn -o TARGET,SOURCE,OPTIONS | grep -vE '^/(proc|sys|dev|run)|/var/lib/(docker|kubelet|rancher|containerd)|/run/(k3s|containerd|netns)' | sort
section loops
# только образы, которые есть в этой системе (в контейнерах ядро и loop-устройства общие)
losetup -a 2>/dev/null | sed -n 's/^[^(]*(\(.*\))$/\1/p' | while read -r f; do [[ -e $f ]] && echo "$f"; done | sort
section swap
swapon --show=NAME --noheadings 2>/dev/null | sort
section netns
ip netns list 2>/dev/null | awk '{print $1}' | grep -v '^cni-' | sort
section iptables
iptables-save 2>/dev/null | grep -E 'HARDENING|--dport (8038|8023|8099|20280)\b' | sed -E 's/\[[0-9]+:[0-9]+\]//' | sort
section listen
ss -Hltn 2>/dev/null | awk '{print $4}' | sed 's/.*://' | awk '$1 < 30000' | sort -un

section sysctl-time
sysctl -n vm.swappiness
timedatectl show -p Timezone -p NTP 2>/dev/null

section files
content /etc/fstab /etc/hosts /etc/resolv.conf /etc/sysctl.conf /etc/motd /etc/docker/daemon.json \
  /etc/prometheus/prometheus.yml /etc/postgresql/*/main/pg_hba.conf /etc/postgresql/*/main/postgresql.conf
section dirs
listing /etc/systemd/system /etc/sudoers.d /etc/cron.d /etc/logrotate.d /etc/security/limits.d /etc/sysctl.d \
  /etc/apt/sources.list.d /etc/nginx/sites-enabled /etc/nginx/sites-available /etc/nginx/conf.d \
  /etc/systemd/resolved.conf.d /etc/systemd/journald.conf.d /usr/local/bin /usr/local/sbin \
  /usr/local/share/ca-certificates /etc/prometheus /etc/postgresql/*/main/conf.d /etc/postgresql/* \
  /opt /srv /srv/www /srv/git /mnt /root /var/log/trainer /var/backups /var/cache/trainer /etc/default \
  | grep -vE '^/root/\.|^/var/backups/(apt|dpkg|alternatives|group|gshadow|passwd|shadow)'
section crontab
crontab -l 2>/dev/null

section dpkg
dpkg --audit 2>&1
dpkg-query -W checkout-agent 2>/dev/null

if command -v psql >/dev/null 2>&1 && pg_isready -q 2>/dev/null; then
  section postgres
  (cd / && sudo -u postgres psql -XqAt -c 'SELECT datname FROM pg_database ORDER BY 1' -c 'SELECT rolname FROM pg_roles ORDER BY 1' -c 'SHOW max_connections' -c 'SHOW listen_addresses' 2>/dev/null)
  pg_lsclusters --no-header 2>/dev/null | awk '{print $1, $2, $3}'
fi
if command -v mysql >/dev/null 2>&1 && mysqladmin ping --silent 2>/dev/null; then
  section mysql
  mysql -uroot -NBe "SHOW DATABASES; SELECT CONCAT(user, '@', host, ' ', plugin) FROM mysql.user ORDER BY 1" 2>&1
fi
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  section docker
  docker ps -a --format '{{.Names}}' | sort
  docker network ls --format '{{.Name}}' | sort
  docker images --format '{{.Repository}}:{{.Tag}}' | grep -E '^(trainer/|notes)' | sort
  docker volume ls --format '{{.Name}}' | grep -i notes | sort
fi
if command -v k3s >/dev/null 2>&1 && k3s kubectl get ns >/dev/null 2>&1; then
  section k8s
  k3s kubectl get ns --no-headers -o custom-columns=:metadata.name | sort
fi
exit 0
