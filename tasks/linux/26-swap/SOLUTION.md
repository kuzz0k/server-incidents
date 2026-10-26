# linux-26 · Разбор

## Шаги
```bash
free -h; swapon --show                      # что есть сейчас
mkdir -p /var/lib/swap
fallocate -l 512M /var/lib/swap/trainer.swap  # на btrfs/старых ФС — dd if=/dev/zero bs=1M count=512
chmod 600 /var/lib/swap/trainer.swap
mkswap /var/lib/swap/trainer.swap
swapon /var/lib/swap/trainer.swap
echo '/var/lib/swap/trainer.swap none swap sw 0 0' >> /etc/fstab
swapon -a                                   # проверить, что fstab-запись корректна

echo 'vm.swappiness=10' > /etc/sysctl.d/90-swappiness.conf
sysctl --system                             # или sysctl -w vm.swappiness=10
sysctl vm.swappiness
```

## Пояснения
- `chmod 600` обязателен: в swap попадает содержимое памяти процессов (пароли, ключи).
- `swappiness` (0–200) задаёт, насколько охотно ядро вытесняет анонимную память в swap по сравнению со сбросом page cache. 10 — «только в крайнем случае».

## Доп. вопросы на собеседовании
- Нужен ли swap на сервере? А на ноде Kubernetes? (kubelet исторически требовал swap off)
- Что такое page cache и почему Linux «съедает» всю память под кеш?
- Что такое zram/zswap?
- Чем `sysctl -w` отличается от записи в `/etc/sysctl.d/`? Какие ещё sysctl ты менял? (`net.core.somaxconn`, `fs.file-max`, `vm.max_map_count`)
- Как понять, что сервер активно свопится? (`vmstat 1` — колонки `si`/`so`, `sar -W`)
