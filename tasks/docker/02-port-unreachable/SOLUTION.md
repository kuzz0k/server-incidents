# docker-02 · Разбор

## Шаги диагностики
1. `docker ps` → `0.0.0.0:8202->8080/tcp`: на хосте 8202 проброшен в **8080** контейнера.
2. `docker logs catalog` → `catalog listening on 127.0.0.1:5000`: приложение слушает 5000, и только loopback **внутри** контейнера.
3. `docker inspect catalog --format '{{json .Config.Env}}'` — `BIND=127.0.0.1`, `PORT=5000` из образа.
4. Проверка изнутри: `docker exec catalog wget -qO- 127.0.0.1:5000/health` работает, а с хоста — нет.
   Проброс порта Docker'а приходит на интерфейс `eth0` контейнера, а не на его `lo`.

## Решение
```bash
docker rm -f catalog
docker run -d --name catalog -e BIND=0.0.0.0 -p 8202:5000 trainer/catalog:1.0
curl http://127.0.0.1:8202/health
```

## Как не допустить снова
- В контейнере сервис должен слушать `0.0.0.0`.
- Порт в `EXPOSE` и в `-p` брать из одного места (документация образа).

## Доп. вопросы на собеседовании
- Как работает `-p 8202:5000` под капотом? (DNAT в iptables, docker-proxy)
- Чем `EXPOSE` отличается от `-p`?
- Сети Docker: bridge, host, none, overlay, macvlan. Чем user-defined bridge лучше default bridge? (встроенный DNS по именам)
- Почему порт, опубликованный Docker, доступен снаружи даже при `ufw deny`? (`DOCKER-USER` chain)
- Как пробросить порт только на localhost хоста? (`-p 127.0.0.1:8202:5000`)
