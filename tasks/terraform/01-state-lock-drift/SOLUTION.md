# terraform-01 · Разбор

## Шаги
1. `cd /opt/trainer-tf/site && terraform plan` → `Error acquiring the state lock` и Lock Info: `ID`, `Operation: OperationTypeApply`, `Who: root@host`, `Created`.
2. Кто держит: `ps -ef | grep [t]erraform` → висит `terraform apply -var env=staging`, ждёт ответа `yes`.
   `systemctl status <PID>` → его запустили юнитом `tf-apply-stuck.service`.
   Опасность: если кто-то ответит `yes`, применится **staging** на прод.
3. Безопасно снять блокировку = завершить процесс, который её держит (он ничего ещё не применил):
   ```bash
   systemctl disable --now tf-apply-stuck
   ```
   `terraform force-unlock <ID>` нужен, когда процесса уже нет, а блокировка осталась (типично для remote backend:
   запись в DynamoDB, блокировка в Consul или GCS). Делать его при **живом** процессе нельзя: два apply одновременно испортят state.
4. Дрейф:
   ```bash
   terraform plan          # local_file.app_conf будет пересоздан: содержимое на диске не совпадает с кодом
   terraform apply         # вернуть к коду
   terraform plan -detailed-exitcode; echo $?   # 0
   ```
   `terraform plan -refresh-only` показывает только дрейф, не предлагая изменений из кода.

## Доп. вопросы на собеседовании
- Что такое state, зачем он нужен, что в нём лежит (в том числе секреты)?
- Почему state хранят удалённо (S3 + DynamoDB lock, GCS, Terraform Cloud)? Как работает блокировка?
- Что такое drift и как с ним жить? (`plan -refresh-only`, `apply -refresh-only`, `ignore_changes`)
- Как завести под Terraform ресурс, созданный руками? (`terraform import`, блок `import {}`)
- Как удалить ресурс из state, не удаляя его в реальности? (`terraform state rm`) А пересоздать один ресурс? (`-replace=`)
- Workspaces vs отдельные каталоги для окружений?
