# docker-05 · Разбор

## Что было не так
- `FROM ubuntu` + `build-essential`: сотни мегабайт компиляторов, которые не нужны в рантайме.
- Каждый `RUN apt-get ...` отдельным слоем, без очистки кешей apt/pip.
- `COPY . .` первым: любой изменённый файл инвалидирует кеш и pip ставит всё заново.
- В контекст сборки и в образ уезжает `test-data/` (300 МБ).
- Нет `USER`: процесс работает от root.

## Решение
`.dockerignore`:
```
test-data/
.git
__pycache__/
*.pyc
```
`Dockerfile`:
```dockerfile
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

RUN useradd --system --uid 10001 app
USER 10001

ENV NAME=reports-api PORT=8000
EXPOSE 8000
CMD ["python3", "app.py"]
```
```bash
cd /opt/trainer-docker/reports-api
docker build -t trainer/reports-api:2.0 .
docker images trainer/reports-api
docker history trainer/reports-api:2.0       # какой слой сколько весит
```
Если нужны компиляторы (C-расширения) — multi-stage: собрать wheels в `builder`, а в финальный образ скопировать только их.

## Доп. вопросы на собеседовании
- Как работает кеш слоёв? Что его инвалидирует?
- Зачем multi-stage builds? Пример для Go/Java/Node.
- slim vs alpine vs distroless: плюсы и минусы (musl, отладка, CVE).
- Почему `RUN apt-get update` должен быть в одном `RUN` с `install`?
- Чем `COPY` отличается от `ADD`?
- Как уменьшить поверхность атаки образа? (non-root, read-only rootfs, минимальная база, сканирование: Trivy)
- Что такое `.dockerignore` и как он влияет на скорость сборки?
