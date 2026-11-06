# linux-61 · Разбор

## Шаги диагностики
1. `journalctl -u mirror-sync -n 20` → `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!` и `Host key verification failed`.
   SSH помнит ключ хоста в `~/.ssh/known_hosts` и отказывается подключаться, если хост предъявляет другой ключ:
   так ведёт себя и переустановленный сервер, и атака man-in-the-middle. Отличить их можно только по отпечатку, полученному по другому каналу.
2. Получить ключ, который сервер предъявляет сейчас, и сравнить с присланным:
   ```bash
   ssh-keyscan -p 2222 -t ed25519 127.0.0.1 2>/dev/null | ssh-keygen -lf -
   cat /root/trainer-notes/linux-61.txt
   ```

## Решение
```bash
sudo -u syncer ssh-keygen -R '[127.0.0.1]:2222'                       # убрать старый ключ (бэкап → known_hosts.old)
ssh-keyscan -p 2222 -t ed25519 127.0.0.1 2>/dev/null | sudo -u syncer tee -a ~syncer/.ssh/known_hosts
sudo -u syncer ssh -p 2222 gitmirror@127.0.0.1 true                   # проверка
journalctl -u mirror-sync -n 3
```
Так можно делать только **после** сверки отпечатка. Ещё надёжнее — раздавать ключи хостов централизованно
(`/etc/ssh/ssh_known_hosts` через Ansible, SSHFP-записи в DNS, SSH-сертификаты хостов).

## Доп. вопросы на собеседовании
- Что такое known_hosts и как работает TOFU (trust on first use)?
- Что значат `StrictHostKeyChecking=yes/accept-new/no`? Почему `no` в CI — плохая привычка?
- Как получить отпечаток ключа сервера, не подключаясь к нему? (`ssh-keyscan`, консоль облака, `ssh-keygen -lf /etc/ssh/ssh_host_*_key.pub` на самом сервере)
- Что такое SSH-сертификаты хостов и пользователей?
- Почему после переустановки сервера стоит сохранять его host keys?
