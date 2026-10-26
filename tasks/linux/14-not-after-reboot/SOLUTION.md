# linux-14 · Разбор

## Шаги диагностики
1. `systemctl is-enabled notifier` → `static` или `disabled`.
2. `systemctl enable notifier` → `The unit files have no installation config (WantedBy=, RequiredBy=, Also=, Alias= settings in the [Install] section...)`.
3. `systemctl cat notifier` — секции `[Install]` нет, значит `enable` не знает, к какому target привязать юнит.

## Решение
```bash
cat >> /etc/systemd/system/notifier.service <<'EOF'

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now notifier
ls -l /etc/systemd/system/multi-user.target.wants/ | grep notifier
```
`enable` просто создаёт симлинк в `multi-user.target.wants/`.

## Как не допустить снова
- В каждом юните сервиса должна быть секция `[Install]`.
- После установки сервиса проверять `systemctl is-enabled`.
- Проверять ребутом на стейдже, а не надеяться.

## Доп. вопросы на собеседовании
- Что такое target? Чем `multi-user.target` отличается от `graphical.target`? Аналог runlevel.
- Что делает `systemctl enable` физически? (симлинки)
- Чем `Wants=` отличается от `Requires=`? А `After=` от `Wants=`?
- Зачем `After=network-online.target` и почему одного `After=` недостаточно? (нужен ещё `Wants=`)
- Что такое `static`, `masked`, `indirect` в выводе `is-enabled`?
- Как посмотреть, что тормозит загрузку? (`systemd-analyze blame`, `critical-chain`)
