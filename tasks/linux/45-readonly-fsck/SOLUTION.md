# linux-45 · Разбор

## Шаги диагностики
1. `journalctl -u uploads-api -n 20` → `Read-only file system`.
2. `findmnt /srv/uploads` → опции `ro`. `dmesg | grep -i ext4` — на реальном сервере тут будут `EXT4-fs error … Remounting filesystem read-only`.
3. `dumpe2fs -h /dev/loopX | grep -i -E 'state|errors'` → `Filesystem state: not clean with errors`, `Errors behavior: Remount read-only`.
   Ядро само переводит ext4 в read-only при ошибках, чтобы не испортить данные ещё сильнее (`errors=remount-ro`).
4. `mount -o remount,rw` «помогает», но ФС остаётся с ошибками: следующая ошибка снова переведёт её в ro.

## Решение
```bash
systemctl stop uploads-api              # освободить ФС
umount /srv/uploads                     # fsck только на отмонтированной ФС!
e2fsck -f -y /dev/loopX                 # -f: проверить, даже если «clean»; -y: чинить без вопросов
mount /srv/uploads                      # опции из fstab, rw
dumpe2fs -h /dev/loopX | grep state     # clean
ls /srv/uploads/lost+found              # сюда fsck кладёт «осиротевшие» файлы
systemctl start uploads-api
```
Для корневой ФС: загрузиться в recovery/rescue-образ или `touch /forcefsck` (на systemd: параметр ядра `fsck.mode=force`).

## Доп. вопросы на собеседовании
- Почему нельзя запускать fsck на смонтированной ФС?
- Что делают опции `errors=continue|remount-ro|panic`?
- Что такое lost+found?
- Как проверить диск на сбойные сектора и посмотреть SMART? (`smartctl -a`, `badblocks`)
- Что такое журнал ext4 и почему он не спасает от всех повреждений?
- Чем `xfs_repair` отличается от `e2fsck`?
