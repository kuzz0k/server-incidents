#!/usr/bin/env bash
# Эталонное решение mysql-01 (для tests/selftest.sh)
set -euo pipefail
systemctl stop mariadb
systemctl set-environment MYSQLD_OPTS="--skip-grant-tables --skip-networking"
systemctl start mariadb
mysql -e "FLUSH PRIVILEGES; ALTER USER 'root'@'localhost' IDENTIFIED VIA unix_socket;"
systemctl stop mariadb
systemctl unset-environment MYSQLD_OPTS
systemctl start mariadb
mysql -e "CREATE DATABASE IF NOT EXISTS shop"
zcat /var/backups/mysql/shop-*.sql.gz | mysql shop
mysql <<'SQL'
CREATE USER 'shop'@'localhost' IDENTIFIED BY 'Shop-Pass-2026';
GRANT SELECT, INSERT, UPDATE, DELETE ON shop.* TO 'shop'@'localhost';
SQL
