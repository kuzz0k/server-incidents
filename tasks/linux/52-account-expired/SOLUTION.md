# linux-52 · Разбор

## Шаги диагностики
1. Лог сервера при попытке входа: `journalctl -u ssh -n 30` (или `/var/log/auth.log`).
2. Первая причина: `Authentication tried for reporter with correct key but not from a permitted host`.
   В `authorized_keys` у ключа опция `from="10.20.0.0/16"`: ключ принимается только с этих адресов.
3. Вторая причина (после исправления первой): `pam_unix(sshd:account): account reporter has expired (account expired)`.
   `chage -l reporter` → `Account expires: Jan 01, 2024`. Блокировку проверяет PAM account, и она срабатывает даже при входе по ключу.

## Решение
```bash
# разрешить вход и с локального адреса (или убрать from=, если ограничение больше не нужно)
sed -i 's|from="10.20.0.0/16"|from="10.20.0.0/16,127.0.0.1"|' /home/reporter/.ssh/authorized_keys
chage -E -1 reporter            # снять срок действия учётки
chage -l reporter
```

## Доп. вопросы на собеседовании
- Чем отличаются срок действия **пароля** (`chage -M`) и **учётной записи** (`chage -E`)? Что из этого мешает входу по ключу?
- Чем `usermod -L` (блокировка пароля) отличается от `usermod -e`/`chage -E`? Почему `passwd -l` не мешает входу по ключу?
- Какие опции бывают в `authorized_keys`? (`from=`, `command=`, `no-port-forwarding`, `restrict`, `expiry-time=`)
- Как отключить пользователю вход, не удаляя его? Как правильно увольнять сотрудника на серверах?
- Что делают `pam_unix`, `pam_access`, `pam_nologin`? Что такое `/etc/nologin`?
