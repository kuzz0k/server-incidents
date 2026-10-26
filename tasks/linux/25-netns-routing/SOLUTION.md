# linux-25 · Разбор

## Шаги диагностики (снизу вверх)
1. **L1/L2 — интерфейс:** `ip netns exec tr-client ip link` → `c0 ... state DOWN`.
2. **L3 — адрес:** `ip netns exec tr-client ip addr` → `10.25.0.2/32`. С маской /32 у клиента нет connected-маршрута до 10.25.0.0/24, и роутер «не в его сети».
3. **Маршрут:** `ip netns exec tr-client ip route` — нет маршрута в 10.26.0.0/24 (и нет default).
   `ip netns exec tr-client ip route get 10.26.0.2` → `Network is unreachable`.
4. **Форвардинг:** `ip netns exec tr-router sysctl net.ipv4.ip_forward` → 0. Роутер не пересылает пакеты между интерфейсами.
5. **Обратный путь:** `ip netns exec tr-backend ip route` — backend не знает, куда отвечать в 10.25.0.0/24.
   Видно через `ip netns exec tr-backend tcpdump -ni b0`: SYN приходит, SYN-ACK не уходит.

## Решение
```bash
ip netns exec tr-client ip link set c0 up
ip netns exec tr-client ip addr flush dev c0
ip netns exec tr-client ip addr add 10.25.0.2/24 dev c0
ip netns exec tr-client ip route add default via 10.25.0.1
ip netns exec tr-router sysctl -w net.ipv4.ip_forward=1
ip netns exec tr-backend ip route add 10.25.0.0/24 via 10.26.0.1
ip netns exec tr-client curl -s http://10.26.0.2:8080/
```

## Как не допустить снова
- Диагностику сети вести по слоям, начиная с самого простого (link → addr → route → firewall/forward → обратный путь).
- На реальных серверах `ip_forward` фиксировать в `/etc/sysctl.d/`, маршруты — в netplan.

## Доп. вопросы на собеседовании
- Как пакет выбирает маршрут? Что такое longest prefix match?
- Что такое default gateway? Зачем ARP? Как посмотреть ARP-таблицу? (`ip neigh`)
- Чем отличается `ip route get` от `traceroute`?
- Что такое network namespace и как на этом построены контейнеры Docker? Что такое veth-пара?
- Когда нужен NAT и чем MASQUERADE отличается от SNAT?
- Что такое асимметричная маршрутизация и rp_filter?
