# linux-41 · Разбор

## Эталонное решение
```bash
#!/usr/bin/env bash
# Заводит пользователей из CSV: login,full_name,groups,shell
set -euo pipefail

CSV=${1:?usage: onboard-users.sh <users.csv>}
OUT=/root/onboarding/passwords.txt
install -d -m 700 /root/onboarding
touch "$OUT"; chmod 600 "$OUT"

tail -n +2 "$CSV" | tr -d '\r' | while IFS=, read -r login name groups shell; do
  [[ -z $login ]] && continue
  grep -qx "$shell" /etc/shells || shell=/bin/bash

  IFS=';' read -ra glist <<<"$groups"
  for g in "${glist[@]}"; do
    getent group "$g" >/dev/null || groupadd "$g"
  done

  if id "$login" >/dev/null 2>&1; then
    echo "skip: $login already exists"
  else
    useradd --create-home --comment "$name" --shell "$shell" "$login"
    pass=$(openssl rand -base64 12)
    echo "$login:$pass" | chpasswd
    chage -d 0 "$login"                 # сменить пароль при первом входе
    echo "$login:$pass" >> "$OUT"
    echo "created: $login"
  fi
  # группы добавляем и существующим — так скрипт исправляет и частично заведённых
  usermod -aG "$(IFS=,; echo "${glist[*]}")" "$login"
done
```

## На что смотрят
- `IFS=, read -r` для CSV, обработка `\r` (файлы из Windows), пропуск заголовка.
- Идемпотентность: проверка `id`/`getent` перед созданием.
- Пароли: случайные (`openssl rand`, `pwgen`), `chage -d 0`, файл с правами 600, не в аргументах командной строки
  (`ps` видит аргументы, а `chpasswd` читает stdin).
- На проде — LDAP/FreeIPA/SSSD или Ansible (`ansible.builtin.user`), а не bash.

## Доп. вопросы на собеседовании
- Где хранятся пользователи, группы, хеши паролей? (`/etc/passwd`, `/etc/group`, `/etc/shadow`)
- Чем `useradd` отличается от `adduser`?
- Как заблокировать пользователя, не удаляя его? (`usermod -L`, `chage -E 0`, nologin)
- Что такое primary и supplementary группы? Почему новая группа не видна в текущей сессии?
- Как сделать так, чтобы пользователь мог только `scp`/`sftp`, без shell? (`ForceCommand internal-sftp`, chroot)
