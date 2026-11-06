# linux-53 · Разбор

## Шаги диагностики
1. `journalctl -u reports-web -n 10` → `Permission denied: '/srv/reports/report-…'`.
2. `ls -l /srv/reports` → файлы `-rw------- exporter reports`: группа правильная (setgid каталога работает), но прав у группы нет.
3. Права новых файлов = `0666 & ~umask` (для каталогов `0777 & ~umask`). Откуда umask у сервиса:
   `systemctl show report-exporter -p UMask` → `0077`. У сервисов systemd свой umask (по умолчанию `0022`), `~/.bashrc` и `/etc/login.defs` на него не влияют.
4. Проверка от имени читателя: `sudo -u www-reports cat /srv/reports/<файл>`.

## Решение
```bash
systemctl edit report-exporter
#   [Service]
#   UMask=0027                  # rw для владельца, r для группы, ничего для прочих
systemctl restart report-exporter
chmod g+r /srv/reports/*.txt    # уже созданные файлы
curl http://127.0.0.1:8053/latest
```
Альтернатива — default ACL на каталоге (`setfacl -d -m g:reports:r /srv/reports`): ACL сильнее umask, см. linux-10.

## Доп. вопросы на собеседовании
- Как umask превращается в права файла и каталога? Какие права даст umask 027?
- Где задаётся umask для интерактивных пользователей, для сервисов systemd, для SFTP?
- Зачем setgid на каталоге и почему он не решает проблему прав группы?
- Чем `chmod g+r` отличается от `chmod 640`? Что такое `X` в `chmod -R g+rX`?
- Как дать доступ на чтение другому сервису без группы? (ACL, `SupplementaryGroups=`)
