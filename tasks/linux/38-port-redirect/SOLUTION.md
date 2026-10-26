# linux-38 · Разбор

## Вариант 1: iptables REDIRECT (NAT в ядре)
```bash
# входящие с других машин
iptables -t nat -A PREROUTING -p tcp --dport 8038 -j REDIRECT --to-ports 20280
# локальные подключения (в т.ч. на свой IP) не проходят PREROUTING — нужен OUTPUT
iptables -t nat -A OUTPUT -p tcp -o lo --dport 8038 -j REDIRECT --to-ports 20280
curl http://127.0.0.1:8038/ ; curl http://$(hostname -I | awk '{print $1}'):8038/
```
Сохранить после ребута: `apt install iptables-persistent && netfilter-persistent save`.

Подвох: для `127.0.0.1` правило в OUTPUT работает с REDIRECT, а DNAT на 127.0.0.1 из PREROUTING —
только с `sysctl net.ipv4.conf.all.route_localnet=1`.

## Вариант 2: прокси в userspace
```ini
# /etc/systemd/system/billing-proxy.socket
[Socket]
ListenStream=8038
[Install]
WantedBy=sockets.target

# /etc/systemd/system/billing-proxy.service
[Service]
ExecStart=/usr/lib/systemd/systemd-socket-proxyd 127.0.0.1:20280
```
```bash
systemctl enable --now billing-proxy.socket
```
Или `nginx stream { server { listen 8038; proxy_pass 127.0.0.1:20280; } }`.

## Сравнение
- NAT: без лишнего процесса, приложение видит **реальный IP клиента**; но правила нужно сохранять, их сложнее отлаживать.
- Прокси: просто и наглядно, видно в `ss -ltnp`; приложение видит 127.0.0.1 вместо клиента, есть лишний hop.

## Доп. вопросы на собеседовании
- Через какие цепочки iptables проходит входящий, исходящий и транзитный пакет? Где работает nat?
- Чем REDIRECT отличается от DNAT? SNAT от MASQUERADE?
- Почему локальный трафик не попадает в PREROUTING?
- Как сделать так, чтобы непривилегированное приложение слушало порт 80? (`CAP_NET_BIND_SERVICE`, `ip_unprivileged_port_start`, редирект)
- Как посмотреть NAT-трансляции? (`conntrack -L`)
