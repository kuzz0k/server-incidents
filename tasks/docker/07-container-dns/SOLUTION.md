# docker-07 · Разбор

## Шаги диагностики
1. `docker ps -a` → `web` в `Restarting`. `docker logs web` → `host not found in upstream "api"`.
2. `docker inspect -f '{{json .NetworkSettings.Networks}}' api web` → оба в сети `bridge` (default).
3. В **default bridge** нет встроенного DNS по именам контейнеров (только устаревший `--link`).
   В **пользовательской** сети Docker поднимает DNS на `127.0.0.11`, и контейнеры резолвят друг друга по имени и алиасам.

## Решение
```bash
docker network create trainer-net
# в run.sh добавить --network trainer-net обоим контейнерам
docker run -d --name api --network trainer-net ...
docker run -d --name web --network trainer-net -p 8207:80 ...
docker exec web getent hosts api      # проверка DNS изнутри
```
Если `docker network create` в скрипте запускается повторно, он упадёт, поэтому нужен `docker network inspect trainer-net >/dev/null 2>&1 || docker network create trainer-net`.

## Доп. вопросы на собеседовании
- Какие драйверы сетей есть в Docker (bridge, host, none, overlay, macvlan, ipvlan)?
- Чем default bridge отличается от пользовательского bridge?
- Как работает DNS внутри контейнера? Что за адрес `127.0.0.11`?
- Почему nginx падает при старте, если upstream не резолвится, и как это обойти? (`resolver` + переменная в `proxy_pass`)
- Можно ли подключить контейнер к двум сетям? (`docker network connect`)
