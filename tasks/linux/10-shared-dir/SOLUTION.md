# linux-10 · Разбор

## Шаги
1. Группа-владелец: `chgrp devteam /srv/projects`.
2. Права `2770` + sticky bit → `3770`:
   - `2` (setgid на каталоге) — новые файлы наследуют группу каталога;
   - `1` (sticky) — удалить файл может только его владелец (как в `/tmp`);
   - `770` — полный доступ владельцу и группе, прочим ничего.
3. umask 022 даёт файлам права `644`, и группа не сможет писать. Это решают default ACL:
   ```bash
   setfacl -m g:devteam:rwx /srv/projects
   setfacl -d -m g:devteam:rwx /srv/projects    # default ACL наследуется новыми файлами/каталогами
   getfacl /srv/projects
   ```
   Если у каталога есть default ACL, umask к создаваемым в нём файлам не применяется, права берутся из ACL.

## Решение целиком
```bash
chgrp devteam /srv/projects
chmod 3770 /srv/projects
setfacl -m g:devteam:rwx -m d:g:devteam:rwx /srv/projects
sudo -u dev1 touch /srv/projects/a && ls -l /srv/projects/a && getfacl /srv/projects/a
```

## Подвох: fs.protected_regular
В Ubuntu `sysctl fs.protected_regular = 2`: в каталоге со sticky bit, доступном группе на запись,
нельзя открыть **чужой** файл с флагом `O_CREAT` (так делают `>>`, многие редакторы). Защита от
атак через подмену файлов во «временных» каталогах. Поэтому sticky ставят только на корень общего каталога,
а совместная работа идёт во вложенных каталогах проектов: sticky не наследуется, а setgid и default ACL наследуются.

## Как не допустить проблем
- Не забывать: участникам нужно перелогиниться после добавления в группу (`newgrp`, `id`).
- `+` в выводе `ls -l` означает, что у файла есть ACL.

## Доп. вопросы на собеседовании
- Что делает setgid на каталоге, а что на исполняемом файле?
- Зачем sticky bit на `/tmp`?
- Что такое ACL mask и почему после `chmod g-w` ACL «перестаёт работать»?
- Чем default ACL отличается от access ACL?
- Почему пользователь не получает права новой группы до перелогина?
- Какие ФС поддерживают ACL и как их включить? (ext4/xfs — по умолчанию; опция `acl`)
