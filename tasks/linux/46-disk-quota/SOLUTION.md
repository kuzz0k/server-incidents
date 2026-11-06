# linux-46 · Разбор

## Шаги диагностики
1. `journalctl -u ci-runner -n 20` → `Disk quota exceeded` (EDQUOT), а не `No space left on device` (ENOSPC).
2. `df -h /srv/ci` — места полно. `findmnt -o TARGET,OPTIONS /srv/ci` → `usrquota`.
3. Состояние квот: `repquota -s /srv/ci` (по всем пользователям), `quota -u builder -s`.
   У `builder` занято ~50M при hard-лимите 50M.
4. `quotaon -p /srv/ci` — квоты включены.

## Решение
```bash
setquota -u builder 180M 200M 0 0 /srv/ci      # soft, hard по блокам; 0 0 — без лимита по inode
# или интерактивно: edquota -u builder
repquota -s /srv/ci
curl http://127.0.0.1:8046/health
```

## Доп. вопросы на собеседовании
- Чем soft-лимит отличается от hard? Что такое grace period?
- Квоты по пользователю, группе, проекту (`prjquota`, xfs project quota) — когда что?
- Как включить квоты на ext4 и XFS? (`usrquota`/`grpquota` в fstab, `quotacheck`, `quotaon`; у XFS — опции монтирования и `xfs_quota`)
- Чем `EDQUOT` отличается от `ENOSPC` и от «кончились inode»?
- Как ограничить место для контейнеров или каталогов без квот? (отдельный раздел/LV, loop-образ, `--storage-opt size=`)
