# linux-58 · Разбор

## Где ищутся библиотеки
Динамический компоновщик (`ld.so`) ищет `.so` по порядку:
1. `RPATH`/`RUNPATH`, вшитые в бинарник (`readelf -d bin | grep -i path`);
2. `LD_LIBRARY_PATH`;
3. кеш `/etc/ld.so.cache`, который строит `ldconfig` из `/etc/ld.so.conf` и `/etc/ld.so.conf.d/*.conf`;
4. стандартные `/lib`, `/usr/lib` (и multiarch-каталоги).

## Шаги диагностики
1. `journalctl -u vendor-scanner -n 20` → `OSError: libvnd.so.1: cannot open shared object file`.
2. Для ELF-бинарника это показал бы `ldd /opt/vendor/bin/<binary>` (строка `not found`). Здесь библиотеку грузит python через `ctypes`, но механизм поиска тот же.
3. `ldconfig -p | grep libvnd` — в кеше нет. `ls /opt/vendor/lib` — файл есть, но каталог не в путях поиска.

## Решение
```bash
echo /opt/vendor/lib > /etc/ld.so.conf.d/vendor.conf
ldconfig
ldconfig -p | grep libvnd
systemctl restart vendor-scanner
```
`LD_LIBRARY_PATH` в юните тоже сработал бы, но только для этого сервиса, а CLI-утилиты вендора остались бы сломанными.

## Доп. вопросы на собеседовании
- Что делает `ldd` и почему его опасно запускать на недоверенных бинарниках?
- Чем `RPATH` отличается от `RUNPATH`? Что такое `$ORIGIN`?
- Что такое soname и зачем симлинки `libfoo.so`, `libfoo.so.1`, `libfoo.so.1.2.3`?
- Что такое статическая и динамическая линковка? Почему Go-бинарники часто «просто работают»?
- Почему бинарник, собранный на glibc, не запускается в alpine (musl)?
