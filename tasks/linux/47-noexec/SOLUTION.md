# linux-47 · Разбор

## Шаги диагностики
1. `systemctl status cache-rotate` → `status=203/EXEC`, `Permission denied`.
2. `ls -l /srv/tools/rotate-cache.sh` — права в порядке. `/srv/tools/rotate-cache.sh` от root — тоже `Permission denied`.
3. `findmnt -T /srv/tools/rotate-cache.sh` → опции `noexec`. При `noexec` ядро запрещает `execve()` любых файлов с этой ФС, независимо от прав и пользователя.
4. Но читать файл можно, поэтому интерпретатор, запущенный с другой ФС, спокойно выполнит скрипт: `bash /srv/tools/rotate-cache.sh` работает.
   (Бинарники так не запустить. `noexec` защищает от запуска загруженных бинарников, но не от скриптов: это защита «от дурака», а не граница безопасности.)

## Решение
```bash
systemctl edit cache-rotate
#   [Service]
#   ExecStart=
#   ExecStart=/bin/bash /srv/tools/rotate-cache.sh
systemctl start cache-rotate
systemctl status cache-rotate
```
Пустая строка `ExecStart=` в drop-in обязательна: она сбрасывает исходный ExecStart (иначе у simple/oneshot будет два ExecStart или ошибка).

## Доп. вопросы на собеседовании
- Какие опции монтирования для безопасности знаешь? (`noexec`, `nosuid`, `nodev`, `ro`) Где их обычно ставят? (`/tmp`, `/var/tmp`, `/dev/shm`, `/home`)
- Почему `noexec` не защищает от `bash script.sh` и `python script.py`?
- Как временно перемонтировать с другими опциями? (`mount -o remount,exec`)
- Почему в drop-in нужно сначала написать пустой `ExecStart=`?
- Что значат коды `203/EXEC`, `200/CHDIR`, `217/USER`?
