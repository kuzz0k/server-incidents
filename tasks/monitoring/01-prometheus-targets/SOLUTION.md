# monitoring-01 · Разбор

## Шаги диагностики
1. `systemctl status prometheus`, `journalctl -u prometheus -n 30` → ошибка загрузки правил.
2. `promtool check config /etc/prometheus/prometheus.yml` проверит и конфиг, и подключённые `rule_files`;
   `promtool check rules /etc/prometheus/rules/disk.yml` → ошибка YAML: у `description` неверный отступ (он должен быть внутри `annotations`).
3. После исправления Prometheus стартует. Цели: `curl -s localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health, lastError}'`
   (или вкладка Status → Targets):
   - `node`: `connection refused` на `localhost:9101`, а node_exporter слушает **9100** (`ss -ltnp | grep exporter`);
   - `app`: `server returned HTTP status 404` — `metrics_path: /stats`, а метрики отдаются на `/metrics`
     (`curl localhost:8301/metrics`).

## Решение
```bash
vim /etc/prometheus/rules/disk.yml               # description → внутрь annotations
sed -i "s/localhost:9101/localhost:9100/" /etc/prometheus/prometheus.yml
sed -i "s|metrics_path: /stats|metrics_path: /metrics|" /etc/prometheus/prometheus.yml
promtool check config /etc/prometheus/prometheus.yml
systemctl restart prometheus                     # или reload: kill -HUP / POST /-/reload (с --web.enable-lifecycle)
curl -s localhost:9090/api/v1/rules | jq '.data.groups[].rules[].name'
```

## Доп. вопросы на собеседовании
- Pull vs push модель мониторинга. Когда нужен Pushgateway?
- Типы метрик: counter, gauge, histogram, summary. Почему по counter смотрят `rate()`?
- Как устроены алерты: Prometheus → Alertmanager (группировка, inhibit, silence, маршрутизация)? Зачем `for:`?
- Что такое service discovery (kubernetes_sd, consul_sd, file_sd)? Relabeling?
- Четыре золотых сигнала; RED и USE методологии.
- Как Prometheus хранит данные (TSDB, retention)? Как масштабировать? (federation, Thanos, VictoriaMetrics)
- Что такое cardinality и почему лейбл `user_id` — плохая идея?
