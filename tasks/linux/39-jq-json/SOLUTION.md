# linux-39 · Разбор

```bash
F=/srv/inventory/servers.json
jq length $F                                   # сначала посмотреть структуру
jq '.[0]' $F

# 1. сколько down
jq '[.[] | select(.status == "down")] | length' $F
# 2. горячие в msk-1
jq -r '[.[] | select(.dc == "msk-1" and .cpu_load > 80) | .name] | sort | join(",")' $F
# 3. dc с максимумом up
jq -r '[.[] | select(.status == "up")] | group_by(.dc) | max_by(length) | .[0].dc' $F
# 4. с тегом db
jq '[.[] | select(.tags | index("db"))] | length' $F
# CSV
{ echo "name,dc,ip,status"; jq -r 'sort_by(.name)[] | [.name, .dc, .ip, .status] | join(",")' $F; } > /root/answers/linux-39.csv
```
`@csv` (`jq -r '... | @csv'`) экранирует значения кавычками — по условию они не нужны, поэтому `join(",")`.

На Python то же самое — `json.load` + `csv.writer`; если jq нет, на собеседовании это нормальный ответ.

## Доп. вопросы на собеседовании
- Чем `jq -r` отличается от `jq`? Что делает `select`, `map`, `group_by`, `to_entries`?
- Как обработать JSON на 10 ГБ, который не помещается в память? (`jq --stream`, NDJSON, построчная обработка)
- Как достать поле из ответа API в bash-скрипте? (`curl -s ... | jq -r .token`)
- Чем YAML отличается от JSON? Чем парсить YAML в shell? (`yq`)
