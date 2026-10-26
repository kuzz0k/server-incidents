# docker-04 · Разбор

## Шаги диагностики
1. `df -h /var/lib/docker`, `docker system df` (и `docker system df -v`) — сколько занимают образы, контейнеры, volumes, build cache.
2. `docker images -f dangling=true` — образы `<none>:<none>`, оставшиеся от пересборок с тем же тегом.
3. `docker ps -a -f status=exited` — остановленные контейнеры.
4. Логи: `du -sh /var/lib/docker/containers/*/*-json.log | sort -h`; `docker inspect -f '{{.LogPath}}' chatty`.
   По умолчанию драйвер `json-file` без ограничения размера.

## Решение
```bash
docker container prune -f           # остановленные контейнеры
docker image prune -f               # dangling-образы
# НЕ docker system prune -a: он удалит все образы без контейнеров, в том числе trainer/keep:prod
docker builder prune -f             # кеш сборки (если есть)

cat /etc/docker/daemon.json 2>/dev/null   # не затирать существующие настройки!
cat > /etc/docker/daemon.json <<'EOF'
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "10m", "max-file": "3" }
}
EOF
systemctl restart docker
/opt/trainer-docker/chatty/run.sh     # настройки логов применяются только к новым контейнерам
docker inspect -f '{{.HostConfig.LogConfig}}' chatty
```

## Как не допустить снова
- `log-opts` в daemon.json с первого дня (или драйвер `local`, journald).
- Регулярная очистка на CI-раннерах: `docker system prune -f --filter "until=72h"` по таймеру.
- `/var/lib/docker` — на отдельном разделе, мониторинг места.

## Доп. вопросы на собеседовании
- Что такое dangling-образ? Чем `image prune` отличается от `image prune -a`?
- Почему изменение daemon.json не повлияло на уже запущенный контейнер?
- Какие log-драйверы бывают? (`json-file`, `local`, `journald`, `syslog`, `fluentd`)
- Как устроены слои образа и почему 10 образов от одной базы не занимают 10× места? (overlay2)
- Как экстренно освободить место от лога контейнера без его рестарта? (`truncate -s 0 $(docker inspect -f '{{.LogPath}}' c)`)
- Что ещё занимает место: volumes, build cache. Как найти «осиротевшие» volumes? (`docker volume ls -f dangling=true`)
