# docker-01 · Разбор

## Шаги диагностики
1. `docker ps -a --filter name=payments-api` → `Exited (2)`.
2. `docker logs payments-api` → `can't open file '/app/server.py'`.
3. `docker inspect payments-api --format '{{.Config.Cmd}} {{.State.ExitCode}}'`; что в образе: `docker run --rm --entrypoint ls trainer/payments:1.0 /app` → там `webapp.py`.
4. Исправили CMD, пересобрали → `Exited (1)`, в логах `required setting DB_URL is not set`.

## Решение
```dockerfile
CMD ["python3", "/app/webapp.py"]
```
```bash
docker build -t trainer/payments:1.0 /opt/trainer-docker/payments
```
`run.sh`:
```bash
docker rm -f payments-api >/dev/null 2>&1
docker run -d --name payments-api --restart unless-stopped \
  -e DB_URL=postgres://payments@db.internal:5432/payments \
  -p 8201:8000 trainer/payments:1.0
```

## Как не допустить снова
- Smoke-тест образа в CI (запуск + healthcheck) до выкатки.
- `HEALTHCHECK` в Dockerfile, конфиг через env с понятной ошибкой при отсутствии.
- Секреты (пароли в DB_URL) — через `--env-file`/секреты оркестратора, не в образе.

## Доп. вопросы на собеседовании
- Чем `CMD` отличается от `ENTRYPOINT`? exec-форма vs shell-форма — что будет с сигналами?
- Почему контейнер живёт ровно столько, сколько процесс с PID 1?
- Политики рестарта: `no`, `on-failure`, `always`, `unless-stopped` — разница после ребута хоста?
- Как зайти в контейнер, который сразу падает? (`docker run -it --entrypoint sh image`, `docker commit` упавшего)
- Что значат exit code 137, 139, 143? (SIGKILL/OOM, SIGSEGV, SIGTERM)
