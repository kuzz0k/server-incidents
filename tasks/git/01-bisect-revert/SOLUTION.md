# git-01 · Разбор

## Шаги
1. Убедиться в границах: `git checkout v1.0 && ./run-tests.sh` проходит, `git checkout main && ./run-tests.sh` падает.
2. Двоичный поиск по истории — `git bisect`, можно автоматически:
   ```bash
   cd /srv/git/billing
   git bisect start main v1.0      # bad, good
   git bisect run ./run-tests.sh   # код возврата 0 = good, 1–127 (кроме 125) = bad
   git bisect reset
   ```
   За ~log2(25) ≈ 5 шагов bisect находит первый плохой коммит. Вручную: `git bisect good` / `git bisect bad` на каждом шаге.
3. Посмотреть, что в нём: `git show <hash>` — округление заменено отбрасыванием копеек.

## Решение
```bash
echo "bad_commit=<hash>" > /root/answers/git-01.txt
git revert --no-edit <hash>    # новый коммит с обратными изменениями, история не меняется
./run-tests.sh
git log --oneline -3
```
`git reset --hard <hash>^` тоже «починит» тесты, но выбросит все последующие коммиты и перепишет общую историю.

## Как не допустить снова
- Тесты в CI на каждый PR, защищённая ветка `main` без прямых пушей.
- Маленькие атомарные коммиты с понятными сообщениями — тогда и bisect, и revert дешевле.

## Доп. вопросы на собеседовании
- Чем `git revert` отличается от `git reset` (`--soft`, `--mixed`, `--hard`)?
- Как откатить merge-коммит? (`git revert -m 1 <merge>`)
- Чем `merge` отличается от `rebase`? Когда rebase опасен?
- Что такое `git reflog` и как с его помощью спасти «потерянные» коммиты?
- Что делает `git cherry-pick`?
- Как найти, кто и когда поменял строку? (`git blame`, `git log -S`, `git log -L`)
