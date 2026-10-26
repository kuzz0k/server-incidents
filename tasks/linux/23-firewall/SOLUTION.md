# linux-23 · Разбор

## Шаги диагностики
1. Сервис слушает: `ss -ltnp | grep 8023`. `curl -v --max-time 3 http://127.0.0.1:8023/` — висит до таймаута.
   Висит, а не `Connection refused` — значит, пакеты **отбрасываются** (DROP).
2. `iptables -S` / `iptables -L INPUT -n -v --line-numbers` — первым правилом в INPUT стоит переход в цепочку `HARDENING`.
3. `iptables -L HARDENING -n -v` — там `DROP tcp dpt:8023` (счётчик пакетов растёт при каждом curl).
   На 24.04 те же правила видны и через `nft list ruleset`.
4. Кто ставит правила: `grep -rl 8023 /etc/systemd/system /usr/local/sbin` → `fw-hardening.service` → `/usr/local/sbin/fw-hardening.sh`.

## Решение
```bash
iptables -D HARDENING -p tcp --dport 8023 -j DROP      # сразу, вручную
sed -i '/--dport 8023/d' /usr/local/sbin/fw-hardening.sh   # чтобы не вернулось при загрузке
systemctl restart fw-hardening
iptables -L HARDENING -n
curl http://127.0.0.1:8023/health
```

## Как не допустить снова
- Правила фаервола — в коде (Ansible/Terraform) с ревью.
- После применения — смоук-тест доступности сервисов.

## Доп. вопросы на собеседовании
- Чем DROP отличается от REJECT для клиента? (таймаут vs мгновенный отказ)
- Цепочки INPUT, OUTPUT, FORWARD; таблицы filter, nat, mangle. Через что идёт пакет к локальному процессу?
- Что такое conntrack и правило `-m state --state ESTABLISHED,RELATED -j ACCEPT`?
- Как правила iptables сохраняются между перезагрузками? (`iptables-persistent`, `netfilter-persistent`, ufw, firewalld, nftables.service)
- iptables vs nftables: что такое iptables-nft?
- Как безопасно менять фаервол на удалённом сервере, чтобы не отрезать себя? (`at now + 5 min` с откатом, `iptables-apply`)
