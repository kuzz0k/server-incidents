# linux-43 · Разбор

## Что было не так
```bash
cd $DIR
for f in $(find . -name *.log -mtime 1); do gzip $f; done
rm -f $(find $DIR -name "*.gz" -mtime -7)
```
1. `-name *.log` без кавычек: shell раскрывает glob **до** запуска find. В каталоге есть `api.log`,
   поэтому find ищет только файлы с именем `api.log`.
2. `-mtime 1` — «ровно 1 сутки» (от 24 до 48 часов), а нужно «больше суток»: `-mtime +0`.
3. `-mtime -7` — **моложе** 7 суток. Удалялись свежие архивы, а нужно `+7` (старше 8 суток) или `-mmin +$((7*24*60))`.
4. `for f in $(find ...)` и `rm $(find ...)` ломаются на пробелах: имя `worker 2026.log` превращается в два аргумента.

## Исправленный скрипт
```bash
#!/bin/bash
# Чистка логов приложения: сжать логи старше суток, удалить архивы старше 7 дней
set -euo pipefail
DIR=/var/log/app-cleaner

find "$DIR" -maxdepth 1 -type f -name '*.log' -mtime +0 -exec gzip -- {} +
find "$DIR" -maxdepth 1 -type f -name '*.gz' -mtime +6 -delete
```
`-mtime +6` = «больше 7×24 часов» (find округляет возраст вниз до целых суток).

## Доп. вопросы на собеседовании
- Как работают `-mtime N`, `+N`, `-N`? Чем `-mtime` отличается от `-mmin` и `-newer`?
- Почему glob нужно брать в кавычки в аргументах find?
- `-exec {} \;` vs `-exec {} +` vs `| xargs -0`?
- Почему не стоит парсить вывод `ls`?
- Как это сделать штатно? (logrotate с `maxage`, `systemd-tmpfiles` с возрастом)
