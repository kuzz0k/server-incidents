# postgres-05 · Разбор

## Шаги диагностики
1. `pg_lsclusters` → `orders ... down`. `systemctl status postgresql@<ver>-orders` и
   `journalctl -u postgresql@<ver>-orders` / `/var/log/postgresql/postgresql-<ver>-orders.log`.
2. Первая ошибка: `data directory "/srv/pgdata/orders" does not exist` — диск не смонтирован.
   `findmnt /srv/pgdata` пусто, `lsblk -f` / `blkid` показывают диск с меткой `pgdata`, а в fstab другой UUID.
3. После монтирования: `data directory "/srv/pgdata/orders" has wrong ownership` или `has invalid permissions`.
   При восстановлении копировали без сохранения владельца (`cp -r` вместо `cp -a`/`rsync -a`).

## Решение
```bash
blkid | grep pgdata                                  # реальный UUID
sed -i 's|^UUID=[^ ]* /srv/pgdata |UUID=<uuid> /srv/pgdata |' /etc/fstab
systemctl daemon-reload && mount /srv/pgdata
chown -R postgres:postgres /srv/pgdata/orders
chmod 700 /srv/pgdata/orders
pg_ctlcluster <ver> orders start                     # или systemctl start postgresql@<ver>-orders
psql -p 5433 -d orders -c 'select count(*) from orders'   # от пользователя postgres
```
Чтобы кластер не стартовал раньше диска: `RequiresMountsFor=/srv/pgdata` в drop-in для `postgresql@.service`.

## Доп. вопросы на собеседовании
- Почему PostgreSQL отказывается стартовать при правах шире 0700/0750 на PGDATA?
- Как устроен PGDATA? (`base/`, `pg_wal/`, `postgresql.auto.conf`, `postmaster.pid`)
- Что такое `postmaster.pid` и что будет, если после краша остался старый?
- Как перенести данные PostgreSQL на другой диск правильно?
- Что такое WAL и как PostgreSQL восстанавливается после некорректного выключения?
- Как Debian/Ubuntu управляет несколькими кластерами? (`pg_lsclusters`, `pg_createcluster`, `pg_ctlcluster`)
