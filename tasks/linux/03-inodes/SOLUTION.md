# linux-03 · Разбор

## Шаги диагностики
1. `journalctl -u sessions -n 20` — `No space left on device`.
2. `df -h /var/lib/sessions` — место есть. `df -i /var/lib/sessions` — IUse% = 100%: кончились inode.
3. Где файлы: `find /var/lib/sessions -xdev -type f | cut -d/ -f1-5 | sort | uniq -c | sort -rn | head`
   или `du --inodes -x /var/lib/sessions | sort -n | tail`.
4. `ls /var/lib/sessions/store | wc -l` — около 100 тысяч мелких файлов.
5. Попытка `rm /var/lib/sessions/store/*` → `Argument list too long`: glob раскрывается в слишком длинную строку (ARG_MAX).

## Решение
```bash
find /var/lib/sessions/store -type f -mtime +0 -delete   # старше суток
# вариант для очень старых find: find ... -print0 | xargs -0 rm -f
df -i /var/lib/sessions
curl http://127.0.0.1:8003/health
```

## Как не допустить снова
- Регулярная очистка устаревших сессий (cron/systemd timer, `systemd-tmpfiles` с `e`/`d` и сроком).
- Мониторинг не только места, но и inode (`node_filesystem_files_free` в node_exporter).
- Для миллионов мелких файлов: хранилище с динамическими inode (XFS) или правильный `-N`/`-i` при mkfs, либо вообще Redis/БД для сессий.

## Доп. вопросы на собеседовании
- Что хранится в inode, а что нет (имя файла)? Где хранится имя?
- Можно ли увеличить число inode на существующей ext4? (Нет, только пересоздать ФС; у XFS выделяются динамически)
- Откуда `Argument list too long` и как его обойти? (`find -delete`, `xargs`, `getconf ARG_MAX`)
- Что значат `-mtime +1`, `-mtime 1`, `-mtime -1`? Чем mtime отличается от ctime и atime?
- Почему `ls` в каталоге со 100k файлов тормозит, а `ls -f` — нет?
