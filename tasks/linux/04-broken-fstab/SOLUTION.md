# linux-04 · Разбор

## Шаги диагностики
1. `mount -a` → `wrong fs type, bad option` для `/backup`; `/data` молча не монтируется (nofail + нет устройства).
2. `findmnt --verify` — покажет, что для `/data` указан несуществующий UUID и что в опциях `/backup` опечатка.
3. `lsblk -f` или `blkid` — реальные UUID и метки дисков; сравни с fstab.
4. `journalctl -b | grep -i mount` / `systemctl status data.mount` — что пыталось смонтироваться при загрузке.
5. Убедись, что выбрал правильный диск: `mount /dev/loopX /mnt && cat /mnt/.disk-id`.

## Решение
```bash
blkid                                   # находим UUID нового диска с .disk-id=data
vim /etc/fstab                          # UUID для /data → новый, defualts → defaults
systemctl daemon-reload                 # systemd генерирует .mount-юниты из fstab
mount -a && findmnt /data /backup
findmnt --verify
```

## Как не допустить снова
- После любой правки fstab: `findmnt --verify` и `mount -a` до перезагрузки.
- Для некритичных дисков — `nofail` (и `x-systemd.device-timeout=`), чтобы сервер не падал в emergency mode.
- Монтировать по UUID/LABEL, а не по `/dev/sdX`.

## Доп. вопросы на собеседовании
- Что означают 6 полей fstab, особенно 5-е (dump) и 6-е (fsck pass)?
- Что будет при загрузке, если в fstab диск без `nofail`, которого нет? Как выбраться из emergency mode без SSH?
- Как systemd обрабатывает fstab? (`systemd-fstab-generator`, юниты `data.mount`)
- UUID, PARTUUID, LABEL — чем отличаются? Где посмотреть? (`blkid`, `lsblk -f`)
- Чем `mount -a` отличается от `systemctl start data.mount`?
- Как смонтировать ФС только для чтения или с `noexec`, зачем это нужно?
