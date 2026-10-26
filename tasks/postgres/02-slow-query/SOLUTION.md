# postgres-02 · Разбор

## Шаги диагностики
1. Найти запрос:
   - лог: `tail -f /var/log/postgresql/postgresql-*-main.log` → `duration: 250 ms  statement: SELECT ... FROM events WHERE user_id = ... AND created_at > ...`;
   - или живьём: `select pid, now() - query_start, query from pg_stat_activity where state = 'active';`
   - на проде — расширение `pg_stat_statements` (`order by total_exec_time desc`).
2. План:
   ```sql
   EXPLAIN (ANALYZE, BUFFERS)
   SELECT id, type, created_at FROM events
   WHERE user_id = 4242 AND created_at > now() - interval '30 days'
   ORDER BY created_at DESC LIMIT 20;
   ```
   → `Parallel Seq Scan on events`, `Rows Removed by Filter: ~2 000 000`. Читается вся таблица ради пары десятков строк.
3. `\d events` — индексов, кроме PK, нет.

## Решение
```sql
CREATE INDEX CONCURRENTLY idx_events_user_created ON events (user_id, created_at DESC);
ANALYZE events;
```
Порядок колонок важен: сначала колонка равенства (`user_id`), потом диапазона/сортировки (`created_at`). Такой индекс отдаёт строки уже отсортированными, и `LIMIT` останавливается рано.
`CONCURRENTLY` — чтобы не блокировать запись на время построения (нельзя внутри транзакции).

## Как не допустить снова
- `pg_stat_statements` + алерты на рост времени запросов, `auto_explain` для медленных.
- Ревью миграций: новые запросы — с EXPLAIN на продовом объёме данных.

## Доп. вопросы на собеседовании
- Как читать EXPLAIN ANALYZE? Чем cost отличается от actual time? Что такое loops?
- Какие типы сканов знаешь? (Seq, Index, Index Only, Bitmap Heap/Index)
- Когда PostgreSQL не будет использовать индекс, даже если он есть? (низкая селективность, функции над колонкой, несоответствие типов, устаревшая статистика)
- Чем B-tree отличается от GIN, GiST, BRIN, hash? Для чего каждый?
- Что такое VACUUM, autovacuum и bloat? Зачем `ANALYZE`?
- Чем опасен `CREATE INDEX` без `CONCURRENTLY` на нагруженной таблице?
