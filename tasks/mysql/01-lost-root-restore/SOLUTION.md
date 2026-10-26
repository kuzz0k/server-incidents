# mysql-01 · Разбор

## Шаги
1. `sudo mysql` → `ERROR 1045 (28000): Access denied for user 'root'@'localhost'`.
2. Сброс доступа через режим без проверки прав (только локально и ненадолго):
   ```bash
   systemctl stop mariadb
   systemctl set-environment MYSQLD_OPTS="--skip-grant-tables --skip-networking"
   systemctl start mariadb
   mysql -e "FLUSH PRIVILEGES; ALTER USER 'root'@'localhost' IDENTIFIED VIA unix_socket;"
   systemctl stop mariadb
   systemctl unset-environment MYSQLD_OPTS
   systemctl start mariadb
   sudo mysql -e 'select current_user()'
   ```
   `FLUSH PRIVILEGES` нужен, чтобы в режиме `skip-grant-tables` заработали команды управления пользователями.
   `--skip-networking` закрывает сеть, пока проверка прав выключена.
3. Восстановление:
   ```bash
   ls -l /var/backups/mysql/
   zcat /var/backups/mysql/shop-*.sql.gz | head -30     # есть ли CREATE DATABASE в дампе?
   mysql -e "CREATE DATABASE IF NOT EXISTS shop"
   zcat /var/backups/mysql/shop-*.sql.gz | mysql shop
   ```
4. Пользователь приложения:
   ```sql
   CREATE USER 'shop'@'localhost' IDENTIFIED BY 'Shop-Pass-2026';
   GRANT SELECT, INSERT, UPDATE, DELETE ON shop.* TO 'shop'@'localhost';
   ```

## Доп. вопросы на собеседовании
- Чем `unix_socket` (MariaDB) / `auth_socket` (MySQL) отличается от пароля? Почему `sudo mysql` работает без пароля?
- Почему `mysqldump` плохо подходит для большой активной базы? Что такое `--single-transaction`? Альтернативы: Percona XtraBackup, mariabackup.
- Как работает репликация master → replica (binlog, relay log, GTID)?
- Чем `'user'@'localhost'` отличается от `'user'@'%'` и `'user'@'127.0.0.1'`?
- `TRUNCATE` vs `DELETE` vs `DROP`?
- Что такое InnoDB buffer pool и какой его размер ставить?
