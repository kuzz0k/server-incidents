# docker-03 · Разбор

## Шаги диагностики
1. `docker compose ps -a`, `docker compose logs web` → `FATAL: cannot connect to database at localhost`.
   Внутри контейнера `localhost` — это сам контейнер `web`, а не база. Сервисы compose видят друг друга по **имени сервиса** (встроенный DNS сети проекта).
2. С `DB_HOST=db` иногда всё равно падает: `connection refused`. `depends_on` в короткой форме ждёт только **запуска** контейнера `db`, а не готовности PostgreSQL.
3. Данные пропадают: у `db` нет volume, данные лежат в слое контейнера и удаляются вместе с ним.

## Решение
```yaml
services:
  web:
    build: ./web
    ports:
      - "8203:8000"
    environment:
      DB_HOST: db
      DB_USER: notes
      DB_PASSWORD: notes
      DB_NAME: notes
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: notes
      POSTGRES_PASSWORD: notes
      POSTGRES_DB: notes
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U notes -d notes"]
      interval: 2s
      timeout: 3s
      retries: 20
    restart: unless-stopped

volumes:
  pgdata:
```
```bash
cd /opt/trainer-docker/notes
docker compose up -d --wait
curl -X POST --data 'hello' http://127.0.0.1:8203/notes
docker compose down && docker compose up -d --wait && curl http://127.0.0.1:8203/notes
```

## Как не допустить снова
- Приложение само ретраит подключение к БД при старте, а не падает с первой попытки.
- Healthcheck у всех stateful-сервисов, `depends_on: condition: service_healthy`.
- Пароли — в `.env`/secrets, а не в compose.yaml.

## Доп. вопросы на собеседовании
- Чем named volume отличается от bind mount? Где docker хранит volume? (`docker volume inspect`)
- Что удалит `docker compose down -v`?
- Как сервисы compose находят друг друга? Что такое сеть проекта?
- Чем `depends_on` отличается от healthcheck и от ожидания в самом приложении?
- Как обновить один сервис без простоя остальных? (`docker compose up -d --no-deps web`)
- Почему БД в контейнере на проде — предмет споров?
