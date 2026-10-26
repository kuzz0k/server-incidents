# docker-06 · exec /entrypoint.sh: no such file or directory

**Уровень:** Junior · **Тема:** Docker / образы · **Время:** ~15 мин

## Легенда
Воркер собирается из `/opt/trainer-docker/worker` (там `Dockerfile` и `entrypoint.sh`) и запускается
скриптом `run.sh`. Контейнер падает сразу с ошибкой `exec /entrypoint.sh: no such file or directory`,
хотя файл в образе точно есть: `docker run --rm --entrypoint ls trainer/worker:1.0 -l /entrypoint.sh`.

## Задача
Почини образ, чтобы контейнер `worker` работал и писал в лог `worker started`.

## Ограничения
- База образа — `alpine` (маленький образ), bash в образ не добавлять.

## Критерии готовности (что проверяет check)
Check запускает `run.sh` (он пересобирает образ), затем:
- контейнер `worker` работает 5 секунд, в логах `worker started`
- образ на alpine, bash в нём нет

> Теория по теме — [THEORY.md](THEORY.md) (`sudo ./trainer.sh theory docker-06`).
> Не читай `break.sh` и `check.sh` — там спойлеры.
