# linux-60 · Разбор

## Шаги диагностики
1. `journalctl -u media-api -n 10` → `Permission denied`.
2. `ls -l /srv/media-store` показывает владельца числом (`1501 1501`): такого UID на этом сервере нет.
   `ls -ln` — всегда числа. `id media` → у `media` здесь другой UID.
3. В ФС хранятся **числовые** UID/GID, а не имена. Архив (`tar` с `--numeric-owner`, `rsync -a` без маппинга)
   перенёс числа со старого сервера, где у `media` был UID 1501.
4. `find /srv/media-store -nouser -o -nogroup` — всё «осиротевшее».

## Решение
```bash
chown -R media:media /srv/media-store
# точечно, если в дереве есть файлы других владельцев:
# find /srv/media-store -uid 1501 -exec chown media {} + ; find … -gid 1501 -exec chgrp media {} +
systemctl restart media-api
```
Как не допустить: одинаковые UID/GID на всех серверах (LDAP/SSSD, или фиксированные UID при создании),
`rsync --usermap/--groupmap`, `tar` без `--numeric-owner` (тогда маппинг идёт по именам).

## Доп. вопросы на собеседовании
- Что хранится в inode: имя пользователя или UID? Где связь UID ↔ имя?
- Чем это опасно для NFS и Docker-volume'ов (UID в контейнере ≠ UID на хосте)?
- Как сменить UID пользователя и что придётся сделать с его файлами?
- Что делает `rsync -a` с владельцами? А `--numeric-ids`?
- Что такое user namespaces и idmapped mounts?
