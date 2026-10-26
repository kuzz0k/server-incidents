# linux-40 · Разбор

## Эталонное решение
```bash
#!/usr/bin/env bash
# Алерт о заполнении файловых систем: disk-alert.sh [THRESHOLD]
set -uo pipefail

THRESHOLD=${1:-85}
if [[ ! $THRESHOLD =~ ^[0-9]+$ ]] || (( THRESHOLD > 100 )); then
  echo "usage: disk-alert.sh [THRESHOLD 0-100]" >&2
  exit 2
fi

alert=0
while read -r target pcent; do
  use=${pcent%\%}
  [[ $use =~ ^[0-9]+$ ]] || continue
  if (( use >= THRESHOLD )); then
    msg="ALERT: $target is ${use}% full (threshold ${THRESHOLD}%)"
    echo "$msg" >&2
    logger -t disk-alert -p user.warning "$msg"
    alert=1
  fi
done < <(df --output=target,pcent -x tmpfs -x devtmpfs -x overlay -x squashfs | tail -n +2)

exit "$alert"
```
Расписание:
```bash
echo '*/5 * * * * root /usr/local/bin/disk-alert.sh >/dev/null 2>&1' > /etc/cron.d/disk-alert
```

## На что смотрят
- Парсинг `df` без `awk '{print $5}'` по позициям: длинные имена устройств переносят строку; `df -P` или `--output=` (вместе их не указать) от этого спасают.
- Исключение псевдо-ФС, кавычки, проверка аргумента, осмысленный код возврата.
- Почему порог по inode тоже важен (`df -i`, см. linux-03).
- В реальной жизни это делает мониторинг (node_exporter + Alertmanager), скрипт — временное решение.

## Доп. вопросы на собеседовании
- Как отправить алерт в Telegram/Slack из bash? (`curl` в webhook)
- Как не спамить одним и тем же алертом каждые 5 минут? (файл состояния, дедупликация)
- Что вернёт `df` для read-only ФС и сетевых (NFS), если сервер недоступен? Как не повиснуть? (`timeout`, `-l`)
- Какие правила Prometheus написал бы вместо скрипта? (`node_filesystem_avail_bytes / node_filesystem_size_bytes`)
