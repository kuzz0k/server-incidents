# linux-09 · Разбор

## Шаги диагностики
1. Подробный вывод клиента: `ssh -v -i ... alice@127.0.0.1` — ключ предлагается, но сервер его не принимает.
2. Лог сервера — самое полезное: `journalctl -u ssh -n 30` (или `/var/log/auth.log`):
   `Authentication refused: bad ownership or modes for directory /home/alice`.
3. `namei -l /home/alice/.ssh/authorized_keys` — права и владельцы на всём пути.
4. После починки прав вход проходит, но сразу закрывается: `This account is currently not available` → `getent passwd alice` → shell `/usr/sbin/nologin`.

## Решение
```bash
chmod 755 /home/alice            # или 750/700: главное — без записи для group/other
chown -R alice:alice /home/alice/.ssh
chmod 700 /home/alice/.ssh
chmod 600 /home/alice/.ssh/authorized_keys
usermod -s /bin/bash alice
```

## Как не допустить снова
- Добавлять ключи через `ssh-copy-id` или конфиг-менеджмент, а не руками от root.
- Помнить про StrictModes: home, `~/.ssh` и `authorized_keys` должны принадлежать пользователю (или root) и не быть доступны на запись другим.

## Доп. вопросы на собеседовании
- Как работает аутентификация по ключу? Что передаётся по сети, а что нет?
- Что такое `known_hosts` и что значит предупреждение `REMOTE HOST IDENTIFICATION HAS CHANGED`?
- Как запретить вход по паролю и вход root? Что проверить перед тем, как применить такой конфиг? (`sshd -t`, не закрывать текущую сессию)
- Что такое ssh-agent и agent forwarding? Чем опасен forwarding?
- Как ходить через bastion? (`ProxyJump`, `-J`)
- Как ограничить, что можно делать по конкретному ключу? (`command=`, `from=` в authorized_keys)
