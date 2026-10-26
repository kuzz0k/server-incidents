# postgres-03 · Разбор

## Шаги
1. Какой формат у бэкапа: `file /var/backups/postgres/*` или `pg_restore -l <файл> | head`. Это custom-формат (`pg_dump -Fc`), его читает `pg_restore`.
2. Что внутри: `pg_restore -l crm-*.dump | grep -i deals` — отдельные элементы: TABLE, SEQUENCE, DEFAULT, TABLE DATA, SEQUENCE SET, CONSTRAINT (PK), FK CONSTRAINT.
3. `pg_restore -t deals` восстановит только определение таблицы и данные, **без** PK, FK и sequence. Чтобы вернуть всё, используем список:

## Решение
```bash
cd /var/backups/postgres
pg_restore -l crm-*.dump | grep -E '\sdeals(_|\s|$)' > /tmp/deals.list
cat /tmp/deals.list
sudo -u postgres pg_restore -d crm -L /tmp/deals.list crm-*.dump
sudo -u postgres psql -d crm -c '\d deals' -c 'select count(*), sum(amount) from deals'
```
Альтернатива: восстановить бэкап в отдельную базу `crm_restore` и перенести таблицу через `pg_dump -t deals crm_restore | psql crm`.

## Как не допустить снова
- Права: у приложения/разработчиков нет `DROP` на проде, миграции — через ревью.
- Регулярные тестовые восстановления бэкапов.
- PITR (базовый бэкап + WAL-архив: pgBackRest, WAL-G) — позволяет откатиться на момент перед ошибкой.

## Доп. вопросы на собеседовании
- Чем `pg_dump` (логический бэкап) отличается от `pg_basebackup` (физический)?
- Форматы pg_dump: plain, custom, directory, tar. Когда какой? Что умеет `pg_restore -j`?
- Что такое PITR и как он работает? Зачем WAL-архив?
- Консистентен ли `pg_dump` работающей базы? (да, снапшот транзакции)
- Как бэкапить роли и глобальные объекты? (`pg_dumpall --globals-only`)
- Чем репликация отличается от бэкапа? Почему реплика не спасает от `DROP TABLE`?
