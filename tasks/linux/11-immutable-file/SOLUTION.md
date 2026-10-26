# linux-11 · Разбор

## Шаги диагностики
1. `bash -x /opt/payment/deploy.sh` — падает `sed -i`: `cannot rename ... Operation not permitted`.
2. `ls -l` выглядит нормально, но обычные права тут ни при чём, раз ошибка у root.
3. `lsattr /etc/payment/config.yml` → `----i---------`: атрибут immutable. Такой файл нельзя менять, удалять, переименовывать и линковать даже root.
4. `lsattr /var/log/payment/audit.log` → `-----a--------`: append-only, туда можно только дописывать.

## Решение
```bash
chattr -i /etc/payment/config.yml
/opt/payment/deploy.sh
chattr +i /etc/payment/config.yml
lsattr /etc/payment/config.yml /var/log/payment/audit.log
grep timeout /etc/payment/config.yml
```
Атрибут `+a` у журнала снимать не нужно: скрипт только дописывает (`>>`).

## Как не допустить проблем
- Документировать, где стоят атрибуты, иначе следующий админ потратит час.
- `+i` защищает от случайных изменений, но не от root, который знает про `chattr`. Это не механизм безопасности.

## Доп. вопросы на собеседовании
- Чем атрибуты ФС (`chattr`) отличаются от прав доступа (`chmod`)?
- Почему `sed -i` не работает с immutable-файлом, хотя `echo >>` в append-only работает?
  (`sed -i` создаёт временный файл и делает rename)
- Какие ещё бывают атрибуты? (`a`, `i`, `A` — noatime, `C` — no CoW на btrfs)
- Где применяют append-only на практике? (логи аудита, защита от затирания)
- Как найти все immutable-файлы в каталоге? (`lsattr -R /etc 2>/dev/null | grep -- '-i-'`)
