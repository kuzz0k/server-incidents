# postgres-04 · Разбор

## Шаги диагностики
1. Ошибка приложения: `FATAL: remaining connection slots are reserved for ... superuser` (или `sorry, too many clients already`).
2. Суперпользователь может войти по зарезервированному слоту: `sudo -u postgres psql`.
3. Кто занимает соединения:
   ```sql
   SELECT usename, application_name, client_addr, state, count(*)
   FROM pg_stat_activity WHERE backend_type = 'client backend'
   GROUP BY 1, 2, 3, 4 ORDER BY 5 DESC;
   SHOW max_connections; SHOW superuser_reserved_connections;
   ```
   → 17 соединений `report` в состоянии `idle in transaction`: открыли транзакцию и висят.
4. Как давно: `now() - xact_start`. Такие транзакции ещё и мешают VACUUM.

## Решение
```sql
ALTER ROLE report CONNECTION LIMIT 5;
-- сразу освободить слоты: лимит применяется только к новым подключениям
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE usename = 'report';
-- дополнительно: не давать висеть в открытой транзакции
ALTER ROLE report SET idle_in_transaction_session_timeout = '5min';
```
Воркер переподключится, но получит не больше 5 соединений.

## Как не допустить снова
- Пул соединений: PgBouncer (transaction pooling) перед PostgreSQL.
- `CONNECTION LIMIT` для ролей фоновых сервисов, `idle_in_transaction_session_timeout`.
- Мониторинг: число соединений по состояниям, длинные транзакции (`pg_stat_activity`).

## Доп. вопросы на собеседовании
- Почему у PostgreSQL каждое соединение дорогое? (процесс на соединение, память `work_mem`)
- Что такое PgBouncer и его режимы (session/transaction/statement)? Что ломается в transaction-режиме?
- Чем `pg_cancel_backend` отличается от `pg_terminate_backend`?
- Чем опасны долгие `idle in transaction`? (блокировки, bloat, VACUUM не чистит)
- Что такое `superuser_reserved_connections` и `reserved_connections` (PG16)?
- Как найти блокирующий запрос? (`pg_blocking_pids()`, `pg_locks`)
