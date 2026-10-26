# DevOps-тренажёр: задачи-поломки для собеседований

76 практических задач уровня Junior/Middle. Скрипт ломает голую Ubuntu-VM так, как
ломаются реальные серверы, а ты чинишь её, как на troubleshooting-этапе собеседования.
Около 60% задач (44) — Linux, остальные — nginx, PostgreSQL, MariaDB, Docker, Kubernetes,
Ansible, Terraform, Prometheus и Git. Набор сверен с тем, что дают на собеседованиях и в тренажёрах
вроде SadServers (см. «Откуда задачи»).

В каждой задаче есть:
- `README.md` — легенда, симптомы, задача, ограничения, критерии готовности (без спойлеров);
- `break.sh` — создаёт проблему;
- `check.sh` — проверяет результат (✓/✗ по каждому критерию, итог PASS/FAIL);
- `SOLUTION.md` — шаги диагностики, решение, профилактика и **вопросы, которые зададут дальше на собеседовании**;
- `THEORY.md` — вопросы с ответами из [theory/interview.md](theory/interview.md), относящиеся к теме задачи.

Карта тем и навыков — в [TOPICS.md](TOPICS.md).

## Подготовка VM

- Ubuntu **22.04 или 24.04** (server), доступ по SSH, sudo, интернет.
- 2 vCPU, **4 ГБ RAM** (k3s + Docker + PostgreSQL одновременно; с MariaDB и Prometheus лучше 6 ГБ), **30 ГБ** диска.
- Перед сессией сделай **snapshot VM**: отката у задач нет, чистое состояние возвращает snapshot.

Скопировать тренажёр на сервер (с Mac):
```bash
rsync -av --exclude .git ~/Desktop/devops-interview-tasks/ user@server:~/devops-trainer/
```

На сервере:
```bash
cd ~/devops-trainer
sudo ./trainer.sh setup          # базовые пакеты и инструменты диагностики
sudo ./trainer.sh setup --all    # то же + сразу Docker, PostgreSQL, nginx, k3s (иначе ставятся по требованию)
```

## Как пользоваться

```bash
sudo ./trainer.sh list               # все задачи и прогресс (или: list linux)
sudo ./trainer.sh start linux-01     # сломать и показать описание
sudo ./trainer.sh show linux-01      # описание ещё раз
sudo ./trainer.sh check linux-01     # проверить решение
sudo ./trainer.sh theory linux-01    # теория по теме задачи
sudo ./trainer.sh solution linux-01  # разбор (спросит, точно ли сдаёшься)
```

Ответы для задач-расследований пишутся в `/root/answers/<id>.txt` в формате `key=value`.
Kubernetes: `sudo kubectl …` или `export KUBECONFIG=/etc/rancher/k3s/k3s.yaml`.

**Как тренироваться:** засекай время из `README.md`, решай без `SOLUTION.md` и проговаривай вслух,
что проверяешь и почему, как на собеседовании. После решения прочитай `THEORY.md` и вопросы
из `SOLUTION.md` и ответь на них вслух.

## Безопасность для VM с доступом только по SSH

- Задачи **не трогают** `sshd_config`, основной сетевой интерфейс, default route и корневую ФС.
  Сетевые стенды собраны в network namespaces, «диски» — loop-образы в `/var/lib/devops-trainer/disks`
  (подключаются при загрузке сервисом `trainer-disks.service`).
- Все записи в `/etc/fstab` с `nofail`: ребут не уведёт VM в emergency mode.
- Правила iptables касаются только портов задач. Если сам включаешь `ufw`, сначала `ufw allow 22/tcp`.
- linux-21 (DNS), linux-27 (время), linux-28 и linux-37 (apt/dpkg) ломают установку пакетов. Пока они не решены,
  не запускай задачи, которым нужно что-то поставить (trainer предупредит о незакрытых задачах).
- Задачи используют свои порты: linux `80NN`, nginx `81NN` (бэкенды `91NN`), docker `82NN`, PostgreSQL 5432/5433,
  MariaDB 3306, Prometheus 9090/9100 (+ приложение 8301), Ansible-стенд 8888; k3s/traefik — 80/443.
- Не читай `break.sh` и `check.sh` до решения: там спойлеры.

## Каталог задач

Уровень: **J** — Junior, **M** — Middle. Время — ориентир в минутах.

### Linux (44)

| ID | Задача | Ур. | Мин |
|---|---|---|---|
| [linux-01](tasks/linux/01-disk-full/README.md) | Закончилось место на диске | J | 10 |
| [linux-02](tasks/linux/02-deleted-file-held/README.md) | df показывает 100%, а du — почти пусто | M | 15 |
| [linux-03](tasks/linux/03-inodes/README.md) | No space left on device при свободном месте | M | 15 |
| [linux-04](tasks/linux/04-broken-fstab/README.md) | Диски не монтируются после замены | M | 15 |
| [linux-05](tasks/linux/05-lvm-extend/README.md) | Расширить LVM-том без простоя | M | 15 |
| [linux-06](tasks/linux/06-logrotate/README.md) | logrotate не ротирует логи | M | 15 |
| [linux-07](tasks/linux/07-service-permissions/README.md) | Сервис не может прочитать конфиг | J | 10 |
| [linux-08](tasks/linux/08-sudoers/README.md) | sudo без пароля для деплоя не работает | M | 15 |
| [linux-09](tasks/linux/09-ssh-key-login/README.md) | Не пускает по SSH-ключу | J | 10 |
| [linux-10](tasks/linux/10-shared-dir/README.md) | Общая папка для команды | J | 15 |
| [linux-11](tasks/linux/11-immutable-file/README.md) | root не может изменить файл | J | 10 |
| [linux-12](tasks/linux/12-service-wont-start/README.md) | Сервис не стартует | J | 10 |
| [linux-13](tasks/linux/13-restart-loop/README.md) | Сервис в бесконечном рестарте | J | 10 |
| [linux-14](tasks/linux/14-not-after-reboot/README.md) | Сервис не поднялся после ребута | J | 10 |
| [linux-15](tasks/linux/15-port-busy/README.md) | Address already in use | J | 10 |
| [linux-16](tasks/linux/16-cpu-hog/README.md) | Сервер тормозит: кто-то ест CPU | M | 15 |
| [linux-17](tasks/linux/17-zombies/README.md) | Зомби-процессы | J | 10 |
| [linux-18](tasks/linux/18-too-many-open-files/README.md) | Too many open files | M | 15 |
| [linux-19](tasks/linux/19-oom-killer/README.md) | Сервис убивает OOM killer | M | 15 |
| [linux-20](tasks/linux/20-cron-backup/README.md) | Cron не запускает бэкап | J | 15 |
| [linux-21](tasks/linux/21-dns-broken/README.md) | Не работает DNS | J | 15 |
| [linux-22](tasks/linux/22-hosts-override/README.md) | Имя резолвится не туда | J | 10 |
| [linux-23](tasks/linux/23-firewall/README.md) | Фаервол режет порт сервиса | J | 15 |
| [linux-24](tasks/linux/24-listen-localhost/README.md) | Сервис недоступен с других машин | J | 10 |
| [linux-25](tasks/linux/25-netns-routing/README.md) | Маршрутизация между сетями | M | 25 |
| [linux-26](tasks/linux/26-swap/README.md) | Добавить swap и настроить swappiness | J | 10 |
| [linux-27](tasks/linux/27-time-drift/README.md) | Сбито системное время | J | 10 |
| [linux-28](tasks/linux/28-apt-broken/README.md) | apt не может установить пакеты | J | 15 |
| [linux-29](tasks/linux/29-log-parsing/README.md) | Разбор access.log в консоли | J | 20 |
| [linux-30](tasks/linux/30-backup-script/README.md) | Написать скрипт бэкапа с ротацией | J | 30 |
| [linux-31](tasks/linux/31-fix-deploy-script/README.md) | Починить сломанный deploy.sh | J | 20 |
| [linux-32](tasks/linux/32-find-files/README.md) | Найти файлы по признакам (find) | J | 15 |
| [linux-33](tasks/linux/33-log-writer/README.md) | Кто пишет в этот лог? | J | 10 |
| [linux-34](tasks/linux/34-iowait/README.md) | Высокий load average при простаивающем CPU | M | 20 |
| [linux-35](tasks/linux/35-systemd-timer/README.md) | systemd timer не срабатывает | J | 15 |
| [linux-36](tasks/linux/36-write-unit/README.md) | Написать systemd-юнит для приложения | J | 15 |
| [linux-37](tasks/linux/37-dpkg-interrupted/README.md) | Пакет установился наполовину | J | 15 |
| [linux-38](tasks/linux/38-port-redirect/README.md) | Открыть приложение на другом порту, не меняя его | M | 15 |
| [linux-39](tasks/linux/39-jq-json/README.md) | JSON в CSV: разбор инвентаря через jq | J | 20 |
| [linux-40](tasks/linux/40-disk-alert-script/README.md) | Скрипт-алерт о заполнении дисков | J | 25 |
| [linux-41](tasks/linux/41-onboard-users/README.md) | Завести пользователей по списку | J | 25 |
| [linux-42](tasks/linux/42-journald-disk/README.md) | Журнал systemd съел диск | J | 10 |
| [linux-43](tasks/linux/43-log-cleaner/README.md) | Скрипт очистки логов делает не то | J | 20 |
| [linux-44](tasks/linux/44-client-cant-connect/README.md) | Клиент не достучался до API: куда он ходит? | M | 20 |

### nginx (6)

| ID | Задача | Ур. | Мин |
|---|---|---|---|
| [nginx-01](tasks/nginx/01-bad-gateway/README.md) | 502 Bad Gateway | J | 10 |
| [nginx-02](tasks/nginx/02-wont-start/README.md) | nginx не стартует | J | 10 |
| [nginx-03](tasks/nginx/03-forbidden/README.md) | 403 Forbidden и пропавшие картинки | J | 15 |
| [nginx-04](tasks/nginx/04-api-proxy/README.md) | Reverse proxy для API | M | 20 |
| [nginx-05](tasks/nginx/05-tls/README.md) | HTTPS с внутренним CA | M | 25 |
| [nginx-06](tasks/nginx/06-load-balancer/README.md) | Балансировщик: 502 через раз и 504 на отчётах | M | 20 |

### PostgreSQL (5)

| ID | Задача | Ур. | Мин |
|---|---|---|---|
| [postgres-01](tasks/postgres/01-cant-connect/README.md) | Приложение не может подключиться к БД | J | 20 |
| [postgres-02](tasks/postgres/02-slow-query/README.md) | Медленный запрос | M | 20 |
| [postgres-03](tasks/postgres/03-restore-table/README.md) | Восстановить удалённую таблицу из бэкапа | M | 20 |
| [postgres-04](tasks/postgres/04-too-many-connections/README.md) | Too many connections | M | 20 |
| [postgres-05](tasks/postgres/05-cluster-after-reboot/README.md) | PostgreSQL не поднялся после ребута | M | 20 |

### MySQL / MariaDB (1)

| ID | Задача | Ур. | Мин |
|---|---|---|---|
| [mysql-01](tasks/mysql/01-lost-root-restore/README.md) | MariaDB: потерян пароль root, восстановить базу из дампа | M | 25 |

### Docker (7)

| ID | Задача | Ур. | Мин |
|---|---|---|---|
| [docker-01](tasks/docker/01-container-exits/README.md) | Контейнер сразу завершается | J | 15 |
| [docker-02](tasks/docker/02-port-unreachable/README.md) | Контейнер работает, а порт недоступен | J | 10 |
| [docker-03](tasks/docker/03-compose-app-db/README.md) | Compose: приложение не видит базу | J | 25 |
| [docker-04](tasks/docker/04-docker-disk/README.md) | Docker съел весь диск | M | 20 |
| [docker-05](tasks/docker/05-dockerfile-optimize/README.md) | Оптимизировать Dockerfile | M | 30 |
| [docker-06](tasks/docker/06-exec-no-such-file/README.md) | exec /entrypoint.sh: no such file or directory | J | 15 |
| [docker-07](tasks/docker/07-container-dns/README.md) | Контейнеры не видят друг друга по имени | J | 15 |

### Kubernetes на k3s (6)

| ID | Задача | Ур. | Мин |
|---|---|---|---|
| [k8s-01](tasks/k8s/01-crashloop/README.md) | Pod в CrashLoopBackOff | J | 20 |
| [k8s-02](tasks/k8s/02-imagepull-config/README.md) | ImagePullBackOff и CreateContainerConfigError | J | 15 |
| [k8s-03](tasks/k8s/03-service-no-traffic/README.md) | Service и Ingress не пропускают трафик | M | 25 |
| [k8s-04](tasks/k8s/04-pending/README.md) | Pod завис в Pending | M | 20 |
| [k8s-05](tasks/k8s/05-helm-chart/README.md) | Helm-чарт ставится, но приложение не работает | M | 25 |
| [k8s-06](tasks/k8s/06-networkpolicy-dns/README.md) | Фронтенд не достучался до базы в другом namespace | M | 25 |

### Ansible (2)

| ID | Задача | Ур. | Мин |
|---|---|---|---|
| [ansible-01](tasks/ansible/01-broken-playbook/README.md) | Починить плейбук Ansible | M | 25 |
| [ansible-02](tasks/ansible/02-idempotency/README.md) | Сделать плейбук идемпотентным | J | 25 |

### Terraform (1)

| ID | Задача | Ур. | Мин |
|---|---|---|---|
| [terraform-01](tasks/terraform/01-state-lock-drift/README.md) | Terraform: state заблокирован, а инфраструктура разъехалась с кодом | M | 20 |

### Мониторинг (Prometheus) (1)

| ID | Задача | Ур. | Мин |
|---|---|---|---|
| [monitoring-01](tasks/monitoring/01-prometheus-targets/README.md) | Prometheus не стартует и не видит цели | M | 25 |

### Git (3)

| ID | Задача | Ур. | Мин |
|---|---|---|---|
| [git-01](tasks/git/01-bisect-revert/README.md) | Найти и откатить плохой коммит | J | 20 |
| [git-02](tasks/git/02-secret-in-history/README.md) | Секрет попал в историю Git | M | 25 |
| [git-03](tasks/git/03-merge-conflict/README.md) | Слить ветку с конфликтом | J | 20 |

## Предлагаемый порядок

1. **Неделя 1 — Linux база:** linux-01, 07, 09, 12, 13, 14, 15, 17, 22, 24, 29, 32, 33, 36.
2. **Неделя 2 — Linux глубже:** linux-02, 03, 04, 05, 06, 10, 11, 18, 19, 20, 26, 35, 42, 43.
3. **Неделя 3 — bash и сеть:** linux-30, 31, 39, 40, 41 + linux-08, 16, 21, 23, 25, 27, 28, 34, 37, 38, 44.
4. **Неделя 4 — веб и базы:** nginx-01…06, postgres-01…05, mysql-01.
5. **Неделя 5 — контейнеры и IaC:** docker-01…07, k8s-01…06, ansible-01, 02, terraform-01, monitoring-01, git-01…03.
6. **Финал:** выбирай задачи вслепую (по номеру, не глядя в название) и решай на время.

## Откуда задачи

Набор сверялся со списками задач с собеседований и тренажёров:
[SadServers](https://sadservers.com/scenarios) (~120 сценариев: «кто пишет в лог», cron/timer, df vs du,
Postgres/MySQL, Docker, Helm, Ansible, Terraform, Prometheus), разбор
[10 сценариев на TecMint](https://www.tecmint.com/linux-troubleshooting-interview-questions-scenarios/)
(iowait при свободном CPU, сервис после ребута, DNS, SSH-ключи, OOM),
[KodeKloud: Linux interview questions](https://kodekloud.com/blog/linux-interview-questions/),
[разбор собеседования в Яндекс (Enigma)](https://enigmai.ru/interview/yandex/devops-engineer/),
[21 задача DevOps-инженера (Tproger)](https://tproger.ru/articles/21-zadacha-iz-opyta-devops-inzhenera/) и
[тестовые для junior DevOps (Tproger)](https://tproger.ru/articles/nebolshaja-podborka-testovyh-zadanij-dlja-junior-devops-inzhenera).
Сценарии про взлом и повышение привилегий из этих наборов сознательно не включены.

## Структура

```
trainer.sh              точка входа
lib/common.sh           общие функции: логирование, пакеты, systemd, fstab, ответы
lib/check.sh            хелперы проверок: check, check_http, service_stable, finish
lib/prereqs.sh          ensure_docker / ensure_postgres / ensure_nginx / ensure_k3s
lib/disks.sh            loop-диски, переживающие ребут
lib/apps/webapp.py      демо-сервис (stdlib Python), его используют многие задачи
tasks/<тема>/<NN-slug>/ task.env, README.md, break.sh, check.sh, SOLUTION.md, THEORY.md
theory/interview.md     теория: вопросы с собеседований и ответы
theory/tasks.map        какие вопросы относятся к какой задаче
theory/build.py         собирает THEORY.md задач из interview.md по tasks.map
tests/selftest.sh       самотест: break → check=FAIL → эталонный фикс → check=PASS
tests/fixes/<id>.sh     эталонные фиксы (спойлеры!)
```

## Самотест

Проверяет, что каждая задача ломается и чинится эталонным решением. **Только на одноразовой VM**
(или сделай snapshot и откати после):
```bash
sudo ./tests/selftest.sh all          # ~40–60 минут
sudo ./tests/selftest.sh linux        # одна тема
sudo ./tests/selftest.sh linux-05     # одна задача
```
Логи — в `/var/lib/devops-trainer/selftest/`.

## Теория

`THEORY.md` в задачах **генерируются** — руками их не правь. Ответы правь в `theory/interview.md`,
список вопросов для задачи — в `theory/tasks.map` (точный текст заголовка из interview.md), затем:
```bash
python3 theory/build.py
```
Скрипт предупредит, если вопрос из маппинга не найден (например, после переименования заголовка).

## Как добавить свою задачу

1. Создай `tasks/<тема>/<NN-slug>/` с файлами `task.env`, `README.md`, `break.sh`, `check.sh`, `SOLUTION.md`
   (ID = `<тема>-<NN>`).
2. `break.sh` должен быть идемпотентным: при повторном запуске сначала убирать результат прошлого запуска.
3. `check.sh` проверяет **результат**, а не способ решения, и явно проверяет запреты из «Ограничений».
4. Добавь секцию `[<id>]` с вопросами в `theory/tasks.map` и запусти `python3 theory/build.py`.
5. Добавь эталонный фикс в `tests/fixes/<id>.sh` и прогони `sudo ./tests/selftest.sh <id>`.
