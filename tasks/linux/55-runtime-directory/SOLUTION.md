# linux-55 · Разбор

## Почему так
`/run` — это tmpfs в памяти: при каждой загрузке он пустой. Каталог, созданный руками, живёт до первого ребута.

## Решение (правильное)
```bash
systemctl edit sessiond
#   [Service]
#   RuntimeDirectory=sessiond         # systemd создаёт /run/sessiond при старте с владельцем из User=
#   RuntimeDirectoryMode=0750
systemctl restart sessiond
ls -ld /run/sessiond
```
При остановке сервиса systemd удаляет каталог (если не задан `RuntimeDirectoryPreserve=`).

Альтернатива — tmpfiles.d (если каталог нужен не одному сервису):
```bash
echo 'd /run/sessiond 0750 sessiond sessiond -' > /etc/tmpfiles.d/sessiond.conf
systemd-tmpfiles --create /etc/tmpfiles.d/sessiond.conf
```

## Доп. вопросы на собеседовании
- Чем `RuntimeDirectory=`, `StateDirectory=`, `CacheDirectory=`, `LogsDirectory=` отличаются? Куда указывают?
- Что такое tmpfs? Что лежит в `/run`, `/tmp`, `/dev/shm`? Почему `/tmp` иногда не tmpfs?
- Что делает systemd-tmpfiles и когда запускается? Как он чистит `/tmp`?
- Где хранить pid-файлы и сокеты сервиса?
