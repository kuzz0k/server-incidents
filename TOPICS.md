# Обязательные практические темы

По каждой теме: что нужно уметь руками на собеседовании и какие задачи тренажёра это покрывают.
Здесь — команды и порядок действий при поломке. Теория с ответами лежит в
[theory/interview.md](theory/interview.md), а у каждой задачи свой `THEORY.md` с вопросами по её теме.

## 1. Linux: диски и файловые системы
**Уметь:** найти, что заняло место, и освободить его без потери данных; отличить нехватку места от
нехватки inode; найти удалённый, но открытый файл; починить fstab; расширить LVM онлайн; настроить ротацию логов.

`df -h` · `df -i` · `du -xh --max-depth=1 | sort -h` · `ncdu -x` · `find -xdev -size +100M` · `lsof +L1` ·
`lsblk -f` · `blkid` · `findmnt --verify` · `mount -a` · `pvs/vgs/lvs` · `pvcreate` · `vgextend` · `lvextend -r` ·
`resize2fs` · `logrotate -d` · `truncate -s 0`

→ linux-01, 02, 03, 04, 05, 06, 42 (journald)

## 2. Linux: пользователи, права, sudo, SSH
**Уметь:** читать и выставлять права и владельцев, понимать x на каталоге, setgid/sticky, ACL,
атрибуты ФС; настроить sudo с минимальными правами; починить вход по ключу.

`ls -l` · `namei -l` · `chmod` / `chown` · `sudo -u user test -r` · `setfacl` / `getfacl` · `lsattr` / `chattr` ·
`visudo -c` · `sudo -l -U user` · `journalctl -u ssh` · `ssh -v`

→ linux-07, 08, 09, 10, 11, 41 (заведение пользователей)

## 3. Linux: процессы и systemd
**Уметь:** прочитать статус и логи сервиса, найти ошибку в юните, включить автозагрузку, переопределить
параметры через drop-in, понимать Restart и start-limit, лимиты (nofile, память), OOM, зомби, cron.

`systemctl status / cat / edit / daemon-reload / enable --now / reset-failed` · `journalctl -u x -n 50 -f` ·
`systemctl show -p ...` · `systemd-analyze verify` · `ps -eo pid,ppid,stat,%cpu,cmd --sort=-%cpu` · `top` ·
`strace -p` · `/proc/PID/limits` · `dmesg -T | grep -i oom` · `ss -ltnp` · `kill` и сигналы · `crontab` / `/etc/cron.d`

→ linux-12, 13, 14, 15, 16, 17, 18, 19, 20, 26, 33 (кто пишет в файл), 34 (iowait, D-state), 35 (systemd timer), 36 (написать юнит)

## 4. Linux: сеть
**Уметь:** диагностировать по слоям (интерфейс → адрес → маршрут → фаервол → приложение), отличить
DNS-проблему от сетевой, refused от timeout, найти и поправить правило фаервола, понять bind-адрес.

`ip a` · `ip r` · `ip route get` · `ip neigh` · `ip netns exec` · `ss -tulpn` · `curl -v` · `nc -zv` ·
`dig` · `getent hosts` · `resolvectl status` · `/etc/hosts` · `/etc/nsswitch.conf` · `iptables -L -n -v --line-numbers` ·
`nft list ruleset` · `tcpdump -ni any port X` · `sysctl net.ipv4.ip_forward`

→ linux-21, 22, 23, 24, 25, 38 (проброс порта, NAT), 44 (tcpdump/strace: куда ходит клиент)

## 5. Linux: пакеты, время, система
**Уметь:** починить apt (битые репозитории, блокировки), включить NTP, выставить часовой пояс, добавить swap и sysctl.

`apt-get update` · `fuser -v /var/lib/dpkg/lock-frontend` · `dpkg --configure -a` · `apt-mark` ·
`timedatectl` · `swapon --show` · `mkswap` · `sysctl -w` / `/etc/sysctl.d`

→ linux-26, 27, 28, 37 (dpkg: недонастроенный пакет)

## 6. Bash и обработка текста
**Уметь:** с нуля написать конвейер разбора лога, надёжный скрипт (кавычки, `set -euo pipefail`, коды возврата,
stderr, trap), найти файлы по признакам.

`awk` · `sort | uniq -c | sort -rn` · `cut` · `grep -E` · `sed` · `xargs -0` · `find -mtime/-perm/-nouser/-exec` ·
`shellcheck` · `bash -x`

→ linux-29, 30, 31, 32, 39 (jq: JSON → CSV), 40 (скрипт-алерт по дискам), 43 (find -mtime, пробелы в именах)

## 7. nginx
**Уметь:** читать error.log, понимать 403/404/413/502/504, проксировать с правильными заголовками и путями,
`root` vs `alias`, настроить TLS со своим CA, проверять конфиг перед reload.

`nginx -t` · `systemctl reload nginx` · `tail -f /var/log/nginx/error.log` · `curl -I / -v / -H 'Host: …'` ·
`openssl s_client -connect` · `openssl x509 -noout -text` · `update-ca-certificates`

→ nginx-01, 02, 03, 04, 05, 06 (балансировка, 502/504, таймауты)

## 8. PostgreSQL
**Уметь:** разобрать отказ подключения (listen, pg_hba, роль, GRANT), найти медленный запрос и прочитать EXPLAIN,
восстановить таблицу из дампа, разобраться с соединениями.

`psql` · `\l \du \dt \d+ \dp` · `pg_hba.conf` · `pg_reload_conf()` · `pg_stat_activity` · `pg_terminate_backend` ·
`EXPLAIN (ANALYZE, BUFFERS)` · `CREATE INDEX CONCURRENTLY` · `pg_dump -Fc` · `pg_restore -l / -L / -t`

→ postgres-01, 02, 03, 04, 05 (кластер на отдельном диске после ребута)

## 9. Docker
**Уметь:** понять, почему контейнер упал или недоступен, читать логи и inspect, написать нормальный Dockerfile
(кеш слоёв, малый образ, non-root), собрать compose со здоровыми зависимостями и volume, чистить диск.

`docker ps -a` · `docker logs` · `docker inspect -f` · `docker exec` · `docker run --entrypoint sh` ·
`docker build` · `docker history` · `docker system df` · `docker image/container prune` · `/etc/docker/daemon.json` ·
`docker compose up -d --wait / logs / ps / down`

→ docker-01, 02, 03, 04, 05, 06 (no such file: shebang/CRLF), 07 (DNS между контейнерами)

## 10. Kubernetes
**Уметь:** пройти от симптома к причине через `get` → `describe` → `logs` → events; понимать статусы подов,
пробы, Secret/ConfigMap, Service/Endpoints/Ingress, requests/limits, PVC/StorageClass.

`kubectl get pods -o wide --show-labels` · `kubectl describe` · `kubectl logs --previous` · `kubectl get events --sort-by=.lastTimestamp` ·
`kubectl get endpoints` · `kubectl exec` · `kubectl run -it --rm --image=busybox` · `kubectl edit / patch / set image / set resources` ·
`kubectl rollout status / undo` · `kubectl describe node`

→ k8s-01, 02, 03, 04, 05 (Helm), 06 (NetworkPolicy, DNS между namespace)

## 11. Git
**Уметь:** найти плохой коммит и откатить его, не переписывая общую историю; вычистить секрет из истории.

`git log --oneline --graph` · `git bisect run` · `git revert` · `git reset` (и когда нельзя) · `git reflog` ·
`git filter-repo` · `git push --force-with-lease` · `git check-ignore -v`

→ git-01, 02, 03 (конфликт при merge)

## 12. MySQL / MariaDB
**Уметь:** вернуть доступ root (`--skip-grant-tables`), понимать `unix_socket` vs пароль, снять и залить дамп,
завести пользователя с минимальными правами.

`mysql -e` · `mysqldump --single-transaction` · `zcat dump | mysql db` · `SHOW GRANTS` · `CREATE USER … IDENTIFIED BY` ·
`systemctl set-environment MYSQLD_OPTS=…`

→ mysql-01

## 13. Ansible
**Уметь:** читать ошибки плейбука, чинить YAML, переменные, шаблоны и хендлеры; писать идемпотентно на модулях.

`ansible-playbook --syntax-check / --check --diff / -vvv` · `ansible-inventory --graph` · `ansible -m setup` ·
модули `apt`, `file`, `copy`, `template`, `lineinfile`, `user`, `group`, `service`

→ ansible-01, 02

## 14. Terraform
**Уметь:** разобраться с блокировкой state, увидеть и устранить drift, не ломая state.

`terraform init / plan / apply` · `plan -detailed-exitcode` · `plan -refresh-only` · `force-unlock` (и когда нельзя) ·
`state list / show / rm` · `import`

→ terraform-01

## 15. Мониторинг: Prometheus
**Уметь:** поднять Prometheus после ошибки в правилах, понять, почему цель DOWN, проверить конфиг и правила.

`promtool check config / rules` · `/api/v1/targets` · `/api/v1/rules` · `curl host:port/metrics` · `journalctl -u prometheus`

→ monitoring-01

## Чего здесь нет (готовить отдельно)

Эти темы почти всегда спрашивают, но на одной VM их честно не сломать. Ответы на часть вопросов —
в разделах interview.md: «GITLAB CI/CD», «Cloud (AWS)», «Terraform» (remote state, модули), «Рабочий процесс» (SLO/SLA/SLI),
«Python», «Железячные вопросы».
- **CI/CD:** GitLab CI / GitHub Actions — стадии, артефакты, кеш, секреты, runners, стратегии деплоя (rolling, blue-green, canary).
- **IaC глубже:** Terraform-модули, remote backend (S3 + DynamoDB), workspaces; Ansible-роли, Vault, Molecule.
- **Облака:** VPC/подсети/security groups, IAM, балансировщики, managed-БД (AWS/GCP/Yandex Cloud).
- **Мониторинг и логи глубже:** PromQL, Alertmanager, Grafana, Loki/ELK, SLI/SLO, error budget.
- **Сеть глубже:** TCP handshake и состояния, TLS handshake, HTTP/1.1 vs 2, балансировка L4/L7, VPN.
- **Безопасность:** управление секретами (Vault), сканирование образов, принцип минимальных привилегий.
