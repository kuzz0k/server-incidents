# linux-33 · Разбор

## Шаги диагностики
1. Убедиться, что файл растёт: `ls -l` пару раз или `tail -f /var/log/trainer/bad.log`.
2. Кто держит файл открытым: `lsof /var/log/trainer/bad.log` или `fuser -v /var/log/trainer/bad.log` → PID.
   Без этих утилит: `ls -l /proc/*/fd 2>/dev/null | grep bad.log`.
3. Что это за процесс: `ps -fp <PID>`, `systemctl status <PID>` → юнит `report-sync.service`.
4. `kill <PID>` не поможет: у юнита `Restart=always`, процесс вернётся через секунду.

## Решение
```bash
systemctl disable --now report-sync
fuser -v /var/log/trainer/bad.log      # пусто
```

## Подвох, о котором спрашивают
Если программа открывает файл на каждую запись (`echo ... >> file` в цикле), `lsof` её почти не
поймает: файл открыт микросекунды. Тогда помогают `inotifywait -m file`, `auditctl -w file -p wa`
(auditd покажет PID и exe) или `strace -f -e trace=openat -p <PID>` у подозреваемых.

## Доп. вопросы на собеседовании
- Как найти процесс по открытому файлу, по порту, по каталогу? (`lsof`, `fuser -m`, `ss -p`)
- Почему сервис «воскресает» после kill? Как узнать, кто его перезапускает?
- Чем `systemctl stop` отличается от `disable` и от `mask`?
- Как отследить, кто пишет в файл, если он открывается на долю секунды? (auditd, inotify)
- Что будет с записью процесса, если файл удалить? А если переименовать?
