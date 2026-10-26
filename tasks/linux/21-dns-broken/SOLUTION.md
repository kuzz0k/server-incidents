# linux-21 · Разбор

## Шаги диагностики
1. Отделяем сеть от DNS: `ping -c1 1.1.1.1` работает, `ping archive.ubuntu.com` — нет.
2. Кого спрашиваем: `cat /etc/resolv.conf` → `nameserver 192.0.2.53`. `ls -l /etc/resolv.conf` — это обычный файл, а должен быть симлинк на `../run/systemd/resolve/stub-resolv.conf`.
3. Проверить конкретный сервер: `dig @192.0.2.53 archive.ubuntu.com` (таймаут) vs `dig @127.0.0.53 archive.ubuntu.com`.
4. Возвращаем симлинк — снова не работает. `resolvectl status` → `Global: DNS Servers: 192.0.2.53, DNS Domain: ~.`
   Домен `~.` отправляет все запросы на глобальный сервер вместо DNS, полученного по DHCP.
5. Ищем, откуда: `grep -r DNS /etc/systemd/resolved.conf /etc/systemd/resolved.conf.d/`.

## Решение
```bash
ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
rm /etc/systemd/resolved.conf.d/90-corp-dns.conf
systemctl restart systemd-resolved
resolvectl status
resolvectl query archive.ubuntu.com
getent hosts archive.ubuntu.com
```

## Как не допустить снова
- На Ubuntu не редактировать `/etc/resolv.conf` руками: DNS задаётся в netplan (`nameservers:`) или `resolved.conf`.
- После правок — `resolvectl status`.

## Доп. вопросы на собеседовании
- Что происходит при `curl https://example.com` до TCP-соединения? Порядок резолвинга: `/etc/nsswitch.conf` → `/etc/hosts` → DNS.
- Чем `dig`/`nslookup` отличаются от `getent hosts`? (dig идёт прямо в DNS и игнорирует /etc/hosts и nsswitch)
- Что такое 127.0.0.53 и stub-резолвер?
- Записи A, AAAA, CNAME, MX, TXT, NS, PTR, SRV — что для чего?
- Что такое TTL, почему после смены записи «у кого-то работает, у кого-то нет»?
- DNS работает по UDP или TCP? Когда используется TCP?
