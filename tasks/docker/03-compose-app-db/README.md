# docker-03 · Compose: приложение не видит базу

**Уровень:** Junior/Middle · **Тема:** Docker Compose · **Время:** ~25 мин

## Легенда
Сервис заметок: веб-приложение `web` + PostgreSQL `db`, описаны в
`/opt/trainer-docker/notes/compose.yaml`. Разработчик говорит: «у меня локально всё работает».
На сервере:
- `web` падает при старте;
- если его перезапустить руками, иногда поднимается, иногда нет;
- после `docker compose down && docker compose up -d` все заметки пропадают.

API: `GET /notes` — список, `POST /notes` с телом — добавить заметку. Порт на хосте 8203.

## Задача
Почини `compose.yaml` так, чтобы стек стабильно поднимался одной командой
`docker compose up -d`, а данные переживали пересоздание контейнеров.

## Ограничения
- Код приложения (`web/app.py`) не менять.
- База — в контейнере `postgres:16-alpine`, данные — в docker volume.

## Критерии готовности (что проверяет check)
Check делает `docker compose down` (без `-v`), затем `docker compose up -d --wait`, добавляет
заметку, снова `down` + `up -d --wait` и проверяет, что заметка на месте.

> Теория по теме — [THEORY.md](THEORY.md) (`sudo ./trainer.sh theory docker-03`).
> Не читай `break.sh` и `check.sh` — там спойлеры.
