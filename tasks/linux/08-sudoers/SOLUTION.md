# linux-08 · Разбор

## Шаги диагностики
1. `sudo -l -U deploy` — какие правила реально применяются к пользователю. Правила из `deploy.conf` в списке нет.
2. `ls -l /etc/sudoers.d/` и `grep includedir /etc/sudoers` — sudo читает файлы из `sudoers.d`, но **пропускает файлы с точкой в имени и с `~` на конце** (см. `man sudoers`, раздел про `@includedir`).
3. Переименовываешь в `deploy` — пароль всё равно спрашивают. В `sudo -l -U deploy` правило уже есть, но после него идёт `(ALL : ALL) ALL` от группы `ops`.
4. В sudoers при нескольких подходящих правилах **побеждает последнее**, а файлы из `sudoers.d` читаются в лексикографическом порядке: `deploy` < `ops-admins`, поэтому правило `%ops ... ALL` (с паролем) перекрывает NOPASSWD.

## Решение
Файл без точки в имени, который читается **после** `ops-admins` (проверь `ls /etc/sudoers.d | sort`):
```bash
mv /etc/sudoers.d/deploy.conf /etc/sudoers.d/zz-deploy
chmod 440 /etc/sudoers.d/zz-deploy
visudo -cf /etc/sudoers.d/zz-deploy && visudo -c
sudo -l -U deploy
sudo -u deploy sudo -n systemctl restart webhook
```
Содержимое:
```
deploy ALL=(root) NOPASSWD: /usr/bin/systemctl restart webhook, /usr/bin/systemctl status webhook
```

## Как не допустить снова
- Редактировать только через `visudo -f /etc/sudoers.d/<file>`: он проверит синтаксис.
- Имена файлов в `sudoers.d` — без точек и с префиксом, задающим порядок (`10-…`, `90-…`); у всех файлов одна схема именования.
- После изменения — `sudo -l -U <user>`.

## Доп. вопросы на собеседовании
- Что будет, если в sudoers синтаксическая ошибка? Как починить, если sudo сломан? (`pkexec visudo`, root-консоль, single-user mode)
- Почему в правиле нужен полный путь к команде?
- Почему опасно давать `NOPASSWD` на `vim`, `less`, `find`, `tar` и т.п.? (выход в shell, GTFOBins)
- Чем `sudo -i` отличается от `sudo -s` и `su -`?
- Что такое `secure_path` и `env_reset`?
- Где смотреть, кто и что выполнял через sudo? (`journalctl _COMM=sudo`, `/var/log/auth.log`)
