# linux-27 · Разбор

## Шаги диагностики
1. `date`, `timedatectl` — часовой пояс `America/Los_Angeles`, `System clock synchronized: no`, `NTP service: inactive`.
2. Реальное время для сравнения: `curl -sI http://archive.ubuntu.com | grep -i ^date`.
3. Кто отвечает за синхронизацию: `systemctl status systemd-timesyncd` (или chrony: `chronyc tracking`).

## Решение
```bash
timedatectl set-timezone Etc/UTC
timedatectl set-ntp true            # включает systemd-timesyncd
systemctl restart systemd-timesyncd
timedatectl timesync-status         # сервер, offset
timedatectl                          # System clock synchronized: yes
```
Если timesyncd не установлен: `apt install systemd-timesyncd` (или chrony).

## Как не допустить снова
- NTP включён на всех серверах (chrony/timesyncd), алерт на рассинхронизацию (`node_timex_offset_seconds`).
- Часовой пояс серверов — UTC, локальное время показывать уже в интерфейсах.

## Доп. вопросы на собеседовании
- Почему рассинхрон времени ломает TLS, Kerberos, распределённые БД, JWT-токены, cron?
- Чем `timedatectl set-time` отличается от NTP? Что такое step и slew при коррекции?
- Что такое RTC (hwclock) и почему на VM время может «уплывать»?
- chrony vs ntpd vs systemd-timesyncd?
- Почему хранить в БД время лучше в UTC?
