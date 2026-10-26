# linux-44 · Разбор

## Шаги диагностики
1. Логи: `journalctl -u order-sync -f` — ошибки без деталей. Это нормально для чужого софта.
2. Куда идут пакеты:
   ```bash
   tcpdump -ni lo 'tcp[tcpflags] & tcp-syn != 0'      # видно SYN на 127.0.0.1.8440 и ответный RST
   ```
   Или без tcpdump:
   - `strace -f -e trace=connect -p $(systemctl show -p MainPID --value order-sync)` → `connect(..., sin_port=htons(8440), sin_addr=inet_addr("127.0.0.1"))`;
   - `ss -tnp | grep python` (поймать соединение сложно: оно сразу отклоняется).
3. RST в ответ на SYN = на порту никто не слушает (`Connection refused`). `ss -ltnp | grep 844` → API слушает **8044**, клиент ходит на **8440**: опечатка.
4. Где настройка: `systemctl cat order-sync` → `EnvironmentFile=/etc/default/order-sync` → `API_PORT=8440`.

## Решение
```bash
echo "dest=127.0.0.1:8440" > /root/answers/linux-44.txt
sed -i 's/^API_PORT=.*/API_PORT=8044/' /etc/default/order-sync
systemctl restart order-sync
journalctl -u order-sync -n 5
```

## Доп. вопросы на собеседовании
- Как отличить по tcpdump «порт закрыт» (RST), «пакет отброшен фаерволом» (повторные SYN без ответа) и «хост недоступен» (ICMP unreachable)?
- Основные фильтры tcpdump: `host`, `port`, `src/dst`, `tcp[tcpflags]`. Как сохранить дамп для Wireshark? (`-w file.pcap`)
- Что показывает `strace -e trace=network`? Чем опасен strace на проде? (сильно замедляет процесс)
- Какие ещё бывают причины `Connection refused` и `Connection timed out`?
- Как посмотреть, какие соединения открывает процесс за время работы? (`ss -tnp`, `lsof -i -p PID`, eBPF: `tcpconnect`)
