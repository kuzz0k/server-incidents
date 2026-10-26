# linux-07 · Разбор

## Шаги диагностики
1. `systemctl status inventory`, `journalctl -u inventory -n 20` → `cannot read config ... Permission denied`.
2. `ls -l /etc/inventory/config.ini` → `-rw------- root root`.
3. Проверить от имени сервиса: `sudo -u inventory cat /etc/inventory/config.ini`.
4. После починки конфига `/health` отдаёт 500: `data dir not writable` → `ls -ld /var/lib/inventory` → `root root 755`.
5. Полезно: `namei -l /var/lib/inventory` — права на весь путь.

## Решение
```bash
chown root:inventory /etc/inventory/config.ini
chmod 640 /etc/inventory/config.ini
chown inventory:inventory /var/lib/inventory
chmod 750 /var/lib/inventory
systemctl restart inventory
curl http://127.0.0.1:8007/health
```
Альтернатива для каталога: `StateDirectory=inventory` в юните — systemd сам создаст `/var/lib/inventory` с нужным владельцем.

## Как не допустить снова
- Права выдавать по принципу минимальных привилегий: владелец root, группа сервиса, 640/750.
- Использовать `StateDirectory=`, `ConfigurationDirectory=`, `LoadCredential=` в systemd.
- При переносе файлов сохранять владельцев: `rsync -a`, `cp -a`, `tar -p`.

## Доп. вопросы на собеседовании
- Что значат r/w/x для файла и для каталога? Почему без `x` на каталоге нельзя открыть файл внутри?
- Что такое umask и какие права получит новый файл при umask 027?
- Что такое setuid, setgid, sticky bit? Пример: `/usr/bin/passwd`, `/tmp`.
- Чем `chown user:` отличается от `chown user`?
- Почему `chmod 777` — плохое решение, даже если «работает»?
- Как посмотреть, от какого пользователя работает процесс? (`ps -o user,pid,cmd`, `systemctl show -p User`)
