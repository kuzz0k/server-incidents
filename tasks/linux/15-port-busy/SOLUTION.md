# linux-15 · Разбор

## Шаги диагностики
1. `journalctl -u gateway -n 20` → `cannot bind 0.0.0.0:8015: [Errno 98] Address already in use`.
2. Кто слушает порт: `ss -ltnp 'sport = :8015'` (или `lsof -iTCP:8015 -sTCP:LISTEN`, `fuser 8015/tcp`).
3. По PID находим юнит: `systemctl status <PID>` или `cat /proc/<PID>/cgroup` → `legacy-gw.service`.
4. `systemctl is-enabled legacy-gw` → `enabled`: после ребута он снова займёт порт.

## Решение
```bash
systemctl disable --now legacy-gw      # остановить и убрать из автозагрузки
# systemctl mask legacy-gw             # если нужно гарантировать, что никто не запустит
systemctl restart gateway
curl http://127.0.0.1:8015/
```
Простой `kill <PID>` не поможет: systemd поднимет процесс снова (`Restart=`) или он вернётся после ребута.

## Как не допустить снова
- Выводить сервисы из эксплуатации полностью: disable/mask, удалить юнит и пакет.
- Держать реестр портов (или хотя бы `ss -ltnp` в инвентаризации).

## Доп. вопросы на собеседовании
- Как по PID найти systemd-юнит? По порту — процесс?
- Чем `disable` отличается от `mask`?
- Что такое `SO_REUSEADDR` и состояние TIME_WAIT? Почему сервис иногда не может забиндиться сразу после рестарта?
- Может ли непривилегированный процесс слушать порт 80? Как это разрешить? (`CAP_NET_BIND_SERVICE`, `net.ipv4.ip_unprivileged_port_start`)
- Чем `0.0.0.0:8015` отличается от `127.0.0.1:8015` и `[::]:8015`?
