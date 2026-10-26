# git-03 · Разбор

## Шаги
```bash
cd /srv/git/webapp
git log --oneline --graph --all          # где ветки разошлись
git switch main
git merge feature/rate-limit             # CONFLICT (content): Merge conflict in config/app.ini
git status                               # какие файлы в конфликте
git diff                                 # маркеры <<<<<<< ======= >>>>>>>
```
`config/app.ini`: в `main` строка `timeout = 60`, в фиче `timeout = 30` и новая `rate_limit = 100`.
Нужно взять обе: `timeout = 60` и `rate_limit = 100`.
```bash
vim config/app.ini                       # убрать маркеры, оставить обе правки
git add config/app.ini
./run-tests.sh                           # падает: NameError: name 'handle' is not defined
```
Второй, **семантический** конфликт git не увидел: в `main` переименовали `handle()` → `handle_request()`,
а новая функция из фичи вызывает старое имя. Текстово всё слилось, но код сломан. Это ловят только тесты.
```bash
sed -i 's/return handle(path)/return handle_request(path)/' app.py
./run-tests.sh
git add app.py
git commit                               # merge-коммит
git log --oneline --graph -5
```
Полезно: `git mergetool`, `git checkout --ours/--theirs <file>`, `git merge --abort`, `git config rerere.enabled true`.

## Доп. вопросы на собеседовании
- Чем `merge` отличается от `rebase`? Когда что использовать?
- Что такое fast-forward merge? Зачем `--no-ff`?
- Как отменить неудачный merge до коммита и после? (`merge --abort`, `reset --hard ORIG_HEAD`, `revert -m 1`)
- Что такое `ours` и `theirs` при merge и при rebase (они меняются местами)?
- Как уменьшить число конфликтов в команде? (маленькие PR, частые мержи из main, trunk-based)
