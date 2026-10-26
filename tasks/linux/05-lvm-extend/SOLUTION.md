# linux-05 · Разбор

## Шаги диагностики
1. `df -h /srv/app` и `findmnt /srv/app` — источник `/dev/mapper/vgapp-data`.
2. `lsblk` — какие диски есть и что на них; `pvs`, `vgs`, `lvs` — состояние LVM.
3. Новый диск — тот, который виден в `lsblk`, но отсутствует в `pvs` и не имеет ФС (`lsblk -f`).

## Решение
```bash
pvcreate /dev/loopX                      # новый диск → physical volume
vgextend vgapp /dev/loopX                # добавить его в группу томов
lvextend -r -l +100%FREE vgapp/data      # -r сразу расширит ФС (resize2fs / xfs_growfs)
df -h /srv/app
```
Без `-r`: `lvextend -l +100%FREE vgapp/data && resize2fs /dev/vgapp/data`. ext4 и XFS расширяются онлайн.

## Как не допустить снова
- Мониторинг заполнения, алерт заранее.
- Держать запас свободных экстентов в VG.
- Понимать, что уменьшить онлайн нельзя: ext4 уменьшается только отмонтированной, XFS не уменьшается вообще.

## Доп. вопросы на собеседовании
- Что такое PV, VG, LV, PE? Зачем вообще нужен LVM?
- Как расширить диск, если в облаке увеличили размер существующего диска? (`growpart` → `pvresize` → `lvextend -r`)
- Как уменьшить ext4 на LVM? Можно ли уменьшить XFS?
- Что такое LVM snapshot и как его использовать для бэкапа?
- Чем `lvextend -L +1G` отличается от `-l +100%FREE`?
- Что будет с LV, если один из PV в VG умер (linear vs mirror/raid)?
