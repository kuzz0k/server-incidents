# docker-01 · Контейнер сразу завершается

**Уровень:** Junior · **Тема:** Docker · **Время:** ~15 мин

## Легенда
Сервис `payments-api` собирается из `/opt/trainer-docker/payments/Dockerfile` и
запускается скриптом деплоя `/opt/trainer-docker/payments/run.sh`. После последнего
релиза контейнер стартует и сразу умирает, `docker ps` его не показывает.

Сервису нужна строка подключения к базе:
`DB_URL=postgres://payments@db.internal:5432/payments`.

## Задача
Почини образ и скрипт деплоя так, чтобы `run.sh` поднимал рабочий контейнер, который
сам перезапускается при падении и после ребута сервера.

## Ограничения
- Имя контейнера `payments-api`, образ `trainer/payments:1.0`, порт на хосте 8201.

## Критерии готовности (что проверяет check)
Check сам запускает `run.sh`, затем проверяет:
- контейнер `payments-api` работает и не перезапускается 5 секунд
- restart policy `unless-stopped` или `always`
- `curl http://127.0.0.1:8201/health` → 200

> Теория по теме — [THEORY.md](THEORY.md) (`sudo ./trainer.sh theory docker-01`).
> Не читай `break.sh` и `check.sh` — там спойлеры.
