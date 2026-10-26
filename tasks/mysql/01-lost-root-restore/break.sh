#!/usr/bin/env bash
set -euo pipefail
TASK_ID=mysql-01
. "$(dirname "$0")/../../../lib/common.sh"

# Вернуть себе доступ, если задача уже запускалась
if ! mysql -uroot -e 'select 1' >/dev/null 2>&1; then
  pw=$(cat "$TASK_VAR/rootpw" 2>/dev/null || true)
  [[ -n $pw ]] && mysql -uroot -p"$pw" -e "ALTER USER 'root'@'localhost' IDENTIFIED VIA unix_socket" >/dev/null 2>&1 || true
fi
mysql -uroot -e 'select 1' >/dev/null 2>&1 || die "Нет доступа root к MariaDB через сокет — сначала верни его (это и есть задача mysql-01)"
systemctl unset-environment MYSQLD_OPTS 2>/dev/null || true

mysql -uroot <<'SQL'
DROP DATABASE IF EXISTS shop;
DROP USER IF EXISTS 'shop'@'localhost';
CREATE DATABASE shop;
USE shop;
CREATE TABLE customers (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL);
CREATE TABLE orders (id INT AUTO_INCREMENT PRIMARY KEY, customer_id INT NOT NULL, total DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id));
INSERT INTO customers (name) SELECT CONCAT('Customer ', seq) FROM seq_1_to_500;
INSERT INTO orders (customer_id, total) SELECT 1 + seq % 500, ROUND(seq * 3.7, 2) FROM seq_1_to_2000;
SQL
mkdir -p /var/backups/mysql
rm -f /var/backups/mysql/shop-*.sql.gz
mysqldump -uroot --single-transaction shop | gzip > "/var/backups/mysql/shop-$(date -d yesterday +%F).sql.gz"
mysql -uroot -e 'DROP DATABASE shop'

pw=$(head -c 24 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 20)
echo "$pw" > "$TASK_VAR/rootpw"
chmod 600 "$TASK_VAR/rootpw"
mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('$pw')"
