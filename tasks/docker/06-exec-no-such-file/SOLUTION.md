# docker-06 · Разбор

## Почему «no such file», если файл есть
Ядро запускает скрипт, читая shebang и запуская **интерпретатор** из первой строки. Если интерпретатора
нет, `execve` возвращает `ENOENT`, и сообщение говорит про сам скрипт, хотя не найден интерпретатор.

## Шаги диагностики
1. `docker logs worker` → `exec /entrypoint.sh: no such file or directory`.
2. `docker run --rm --entrypoint sh trainer/worker:1.0 -c 'head -1 /entrypoint.sh | od -c | head -2'`:
   - `#!/bin/bash` — в alpine нет bash (`ls /bin/bash` → нет);
   - `\r \n` в конце строк: файл в CRLF, и ядро ищет интерпретатор `/bin/sh\r`.
3. Та же ошибка бывает у бинарника под другую libc (glibc-бинарник в alpine/musl) или под другую архитектуру
   (`exec format error`), а также у Go-бинарника без `CGO_ENABLED=0` в образе `scratch`.

## Решение
```bash
cd /opt/trainer-docker/worker
sed -i 's/\r$//' entrypoint.sh                 # или dos2unix
sed -i '1s|^#!/bin/bash|#!/bin/sh|' entrypoint.sh
./run.sh
docker logs worker
```
Чтобы не повторилось: `.gitattributes` с `*.sh text eol=lf`, `shellcheck` в CI.

## Доп. вопросы на собеседовании
- Как отлаживать контейнер, который сразу падает? (`--entrypoint sh`, `docker run -it`, `docker cp`, `docker commit`)
- Чем `ENTRYPOINT ["/entrypoint.sh"]` отличается от `ENTRYPOINT /entrypoint.sh`?
- Зачем в entrypoint-скрипте `exec "$@"` в конце?
- Чем отличаются alpine (musl) и debian-slim (glibc)? Какие бывают проблемы с alpine?
- Что такое distroless и scratch-образы? Как их отлаживать?
