#!/usr/bin/env bash
# mysql-01: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=mysql-01
. "$(dirname "$0")/../../../lib/common.sh"

systemctl unset-environment MYSQLD_OPTS 2>/dev/null
root_ok() { mysql -uroot -e 'select 1' >/dev/null 2>&1; }
if ! root_ok; then
  pw=$(cat "$TASK_VAR/rootpw" 2>/dev/null)
  [[ -n $pw ]] && mysql -uroot -p"$pw" -e "ALTER USER 'root'@'localhost' IDENTIFIED VIA unix_socket" >/dev/null 2>&1
fi
if ! root_ok; then
  # пароль поменяли по ходу решения — возвращаем доступ через skip-grant-tables
  systemctl stop mariadb
  systemctl set-environment MYSQLD_OPTS="--skip-grant-tables --skip-networking"
  systemctl start mariadb
  mysql -e "FLUSH PRIVILEGES; ALTER USER 'root'@'localhost' IDENTIFIED VIA unix_socket;" >/dev/null 2>&1
  systemctl stop mariadb
  systemctl unset-environment MYSQLD_OPTS
fi
systemctl is-active -q mariadb && pgrep -af 'mariadbd|mysqld' | grep -q skip-grant && systemctl restart mariadb
systemctl is-active -q mariadb || systemctl start mariadb
wait_until 30 mysqladmin ping --silent
mysql -uroot -e "DROP DATABASE IF EXISTS shop; DROP USER IF EXISTS 'shop'@'localhost';" >/dev/null 2>&1 \
  || warn "Не удалось удалить базу/пользователя shop: нет доступа root"
# вернуть root исходный способ входа (как был до задачи)
orig=$(recall root-auth)
[[ $orig == "CREATE USER "* ]] && mysql -uroot -e "${orig/#CREATE USER/ALTER USER}" >/dev/null 2>&1
rm -rf /var/backups/mysql
exit 0
