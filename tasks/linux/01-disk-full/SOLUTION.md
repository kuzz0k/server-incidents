# linux-01 · Разбор

## Шаги диагностики
1. `systemctl status reports`, `journalctl -u reports -n 50` — в логе `No space left on device`.
2. `df -h` — видно, что `/var/lib/reports` заполнен на 100%.
3. `du -xh --max-depth=2 /var/lib/reports | sort -h` (или `ncdu -x /var/lib/reports`) — основное место занимают `logs/` и `tmp/`.
4. `find /var/lib/reports -xdev -type f -size +10M -exec ls -lh {} +` — огромный `debug.log`, его ротированная копия и брошенные `*.tmp`.

## Решение
```bash
truncate -s 0 /var/lib/reports/logs/debug.log   # обнулить, а не rm: файл может держать процесс
rm -f /var/lib/reports/logs/debug.log.1 /var/lib/reports/tmp/*.tmp
df -h /var/lib/reports
curl -X POST -d test http://127.0.0.1:8001/write
```

## Как не допустить снова
- logrotate для логов приложения (`size`, `rotate`, `compress`), DEBUG-логирование в проде выключено.
- Алерт на заполнение диска на уровне 80–85%, а не на 100%.
- Временные файлы чистить по `find -mtime +N -delete` (cron/systemd timer), например через `systemd-tmpfiles`.

## Доп. вопросы на собеседовании
- Почему `rm` большого лога иногда не освобождает место? Как это найти? (`lsof +L1`, см. linux-02)
- Чем отличаются `df` и `du`, почему их цифры могут расходиться?
- Что такое reserved blocks в ext4 и почему root может писать, когда пользователю уже нельзя? (`tune2fs -m`)
- Как найти 10 самых больших файлов на ФС, не выходя на другие точки монтирования? (`find -xdev`, `du -x`)
- Чем `truncate -s 0 file` отличается от `> file` и от `rm file`?
- Что будет, если место кончится на `/` или на `/var`? Какие сервисы упадут первыми?
