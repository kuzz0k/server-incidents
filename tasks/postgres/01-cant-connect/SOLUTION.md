# postgres-01 · Разбор

Ошибки идут по очереди, каждая — отдельный слой.

1. **Сеть:** `Connection refused` по IP. `ss -ltnp | grep 5432` → только `127.0.0.1`.
   `sudo -u postgres psql -c 'show listen_addresses'` → `localhost`. Откуда: `grep -r listen_addresses /etc/postgresql/*/main/`
   (в `conf.d/` лежит переопределение). Нужно `listen_addresses = '*'` (или конкретный IP) и **рестарт** (reload не хватит).
2. **pg_hba:** `pg_hba.conf rejects connection for host "...", user "shop"` — первая подходящая строка `reject`.
   pg_hba читается сверху вниз до первого совпадения. Удаляем reject и добавляем
   `host shopdb shop 0.0.0.0/0 scram-sha-256` (лучше конкретную подсеть приложения). Применить: `select pg_reload_conf();`.
3. **Роль:** `role "shop" is not permitted to log in` → `ALTER ROLE shop LOGIN;`
4. **Права:** `permission denied for schema shop` → нужны `USAGE` на схему и `SELECT` на таблицу.

## Решение
```bash
D=/etc/postgresql/*/main
sed -i "s/^listen_addresses.*/listen_addresses = '*'/" $D/conf.d/*.conf
sed -i '/^host\s.*shop.*reject/d' $D/pg_hba.conf
echo "host shopdb shop 0.0.0.0/0 scram-sha-256" >> $D/pg_hba.conf
systemctl restart postgresql
sudo -u postgres psql -d shopdb <<'SQL'
ALTER ROLE shop LOGIN;
GRANT USAGE ON SCHEMA shop TO shop;
GRANT SELECT ON ALL TABLES IN SCHEMA shop TO shop;
ALTER DEFAULT PRIVILEGES IN SCHEMA shop GRANT SELECT ON TABLES TO shop;
SQL
```

## Как не допустить снова
- Чек-лист новой БД: listen, pg_hba, роль с LOGIN, GRANT на схему/таблицы, default privileges.
- Права выдавать через групповые роли (`shop_readonly`), а не напрямую.

## Доп. вопросы на собеседовании
- Какие методы аутентификации в pg_hba знаешь? (`peer`, `scram-sha-256`, `md5`, `trust`, `reject`, `cert`)
- Чем `peer` отличается от `md5`? Почему `sudo -u postgres psql` работает без пароля?
- Какие параметры требуют рестарта, а какие — reload? (`pending_restart` в `pg_settings`)
- Что такое `ALTER DEFAULT PRIVILEGES` и зачем он нужен?
- Что изменилось в PostgreSQL 15 с правами на схему `public`?
- Как посмотреть, какие права есть у роли? (`\dp`, `\dn+`, `has_table_privilege`)
