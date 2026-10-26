# git-02 · Разбор

## Шаги
1. Найти, где секрет: `git log --all -p -S TRAINER-FAKE-SECRET` или `git log --all --oneline -- config/prod.env`.
   `git rm` удалил файл только из последующих коммитов: в старых он остался и доступен через `git show <hash>:config/prod.env`.
2. Переписать историю. Рекомендуемый инструмент — `git filter-repo` (`apt install git-filter-repo`):
   ```bash
   cd /srv/git/shop
   git filter-repo --invert-paths --path config/prod.env --force
   ```
   filter-repo сам чистит reflog и делает gc. Он **удаляет remote `origin`**, чтобы ты случайно не запушил не туда — его нужно вернуть.
   Старый способ — `git filter-branch --index-filter 'git rm --cached --ignore-unmatch config/prod.env' -- --all`, после него
   нужно удалить `refs/original/`, сделать `git reflog expire --expire=now --all && git gc --prune=now`.
3. Защититься от повтора:
   ```bash
   echo 'config/prod.env' >> .gitignore      # или *.env + !config/dev.env
   git add .gitignore && git commit -m "ignore prod env"
   ```
4. Обновить remote:
   ```bash
   git remote add origin /srv/git/shop-remote.git
   git push --force origin main
   git push --force --tags origin
   ```
5. Проверить: `git log --all --reflog -p | grep -c TRAINER-FAKE-SECRET` → 0, то же в `/srv/git/shop-remote.git`.

## Важно понимать
- После утечки **сначала ротация секрета**, потом чистка истории: у всех, кто успел склонировать, он уже есть.
- Все коллеги должны переклонировать репозиторий, иначе старая история вернётся при следующем push.
- На GitHub/GitLab старые коммиты могут оставаться доступными по хэшу (кеши, форки, PR) — нужен запрос в поддержку.

## Как не допустить снова
- pre-commit хуки и сканеры секретов (gitleaks, trufflehog) в CI, push protection.
- Секреты — в Vault/SOPS/секретах CI, а не в репозитории.

## Доп. вопросы на собеседовании
- Почему `git rm` + commit не удаляет файл из истории?
- Чем `filter-repo` лучше `filter-branch`? Что такое BFG?
- Чем `push --force` отличается от `--force-with-lease`?
- Что такое объекты git (blob, tree, commit, tag) и почему у переписанных коммитов новые хэши?
- Что такое `.gitignore`, `.git/info/exclude` и `git check-ignore -v`? Почему `.gitignore` не помогает для уже отслеживаемых файлов?
