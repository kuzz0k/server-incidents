# linux-36 · Разбор

## Решение
```bash
useradd --system --no-create-home --shell /usr/sbin/nologin notes
cat > /etc/systemd/system/notes-api.service <<'EOF'
[Unit]
Description=Notes API
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=notes
Group=notes
EnvironmentFile=/etc/notes-api/notes-api.env
WorkingDirectory=/opt/notes-api
ExecStart=/usr/bin/python3 /opt/notes-api/server.py
StateDirectory=notes-api
Restart=on-failure
RestartSec=3
# немного харднинга
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now notes-api
systemctl status notes-api
journalctl -u notes-api -f
```
`StateDirectory=notes-api` создаёт `/var/lib/notes-api` с владельцем из `User=`, и с `ProtectSystem=strict`
это единственный каталог, куда сервис может писать.

## На что смотрят
- `User=` (не root), `Restart=` + `RestartSec=`, `[Install]`, полный путь в `ExecStart`.
- Логи: stdout/stderr уходят в journald сами, `>> /var/log/...` в ExecStart не нужен.
- `After=network-online.target` имеет смысл только вместе с `Wants=`.

## Доп. вопросы на собеседовании
- `Restart=always` vs `on-failure` vs `on-abnormal`? Что такое `StartLimitBurst`?
- `Type=simple`, `exec`, `forking`, `notify`, `oneshot` — когда какой?
- Как ограничить ресурсы сервиса? (`MemoryMax=`, `CPUQuota=`, `TasksMax=`)
- Что дают `ProtectSystem=`, `PrivateTmp=`, `NoNewPrivileges=`, `DynamicUser=`? Как оценить юнит? (`systemd-analyze security`)
- Чем `EnvironmentFile=` отличается от `Environment=`? Где хранить секреты? (`LoadCredential=`)
