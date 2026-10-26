# linux-08 · sudo без пароля для деплоя не работает

**Уровень:** Middle · **Тема:** Linux / sudo · **Время:** ~15 мин

## Легенда
CI деплоит сервис `webhook` по SSH под пользователем `deploy` и в конце выполняет
`sudo systemctl restart webhook`. Для этого коллега добавил правило в
`/etc/sudoers.d/`, но CI всё равно падает: sudo просит пароль, которого у CI нет.
`deploy` также входит в группу `ops`, у которой есть свои права в sudo.

Проверить можно так:
```bash
sudo -u deploy sudo -n systemctl restart webhook
```

## Задача
Сделай так, чтобы `deploy` мог без пароля выполнять `systemctl restart webhook`
и `systemctl status webhook`.

## Ограничения
- Никаких `NOPASSWD: ALL`: всё остальное через sudo без пароля `deploy` делать не должен.
- `deploy` должен остаться в группе `ops`, правило для `ops` не удалять (оно нужно админам).
- Основной `/etc/sudoers` не трогать, только `/etc/sudoers.d/`.
- Если сломаешь синтаксис sudoers, сломаешь sudo всем — проверяй через `visudo -c`.

## Критерии готовности (что проверяет check)
- `sudo -n systemctl restart webhook` и `sudo -n systemctl status webhook` от `deploy` работают
- `sudo -n bash` и `sudo -n cat /etc/shadow` от `deploy` не работают
- `deploy` в группе `ops`, `visudo -c` без ошибок

> Теория по теме — [THEORY.md](THEORY.md) (`sudo ./trainer.sh theory linux-08`).
> Не читай `break.sh` и `check.sh` — там спойлеры.
