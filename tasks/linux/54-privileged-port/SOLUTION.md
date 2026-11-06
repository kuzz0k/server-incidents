# linux-54 · Разбор

## Почему так
Порты ниже `net.ipv4.ip_unprivileged_port_start` (по умолчанию 1024) может открывать только процесс
с capability `CAP_NET_BIND_SERVICE`. У root она есть, у обычного пользователя нет.

## Варианты решения
1. **Ambient capability в юните** — правильный путь для сервисов:
   ```bash
   systemctl edit ldap-proxy
   #   [Service]
   #   AmbientCapabilities=CAP_NET_BIND_SERVICE
   #   CapabilityBoundingSet=CAP_NET_BIND_SERVICE
   systemctl restart ldap-proxy
   grep Cap /proc/$(systemctl show -p MainPID --value ldap-proxy)/status   # CapEff не нулевой
   capsh --decode=<CapEff>
   ```
2. `setcap 'cap_net_bind_service=+ep' /path/to/binary` — для собственного бинарника. Для интерпретатора плохо:
   capability получат все скрипты, которые он запускает.
3. `sysctl net.ipv4.ip_unprivileged_port_start=389` — снимает защиту для всех процессов на сервере.
4. Socket activation (`ldap-proxy.socket`): порт открывает systemd и передаёт дескриптор сервису. Требует поддержки в приложении.
5. Редирект 389 → 10389 (iptables, linux-38).

## Доп. вопросы на собеседовании
- Что такое capabilities? Какие знаешь? (`CAP_NET_BIND_SERVICE`, `CAP_NET_ADMIN`, `CAP_SYS_ADMIN`, `CAP_CHOWN`, `CAP_DAC_OVERRIDE`)
- Чем effective, permitted, inheritable, ambient и bounding отличаются?
- Как посмотреть capabilities процесса и файла? (`/proc/PID/status`, `getpcaps`, `getcap`)
- Как capabilities используются в Docker и Kubernetes? (`--cap-add`, `securityContext.capabilities`)
- Почему `CAP_SYS_ADMIN` называют «новым root»?
