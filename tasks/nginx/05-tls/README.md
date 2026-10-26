# nginx-05 · HTTPS с внутренним CA

**Уровень:** Middle · **Тема:** nginx / TLS, OpenSSL · **Время:** ~25 мин

## Легенда
Внутренний сервис `secure.trainer.local` работает за nginx:
- HTTPS — `https://secure.trainer.local:8443/`
- HTTP — `http://secure.trainer.local:8105/`

У компании свой удостоверяющий центр: сертификат и ключ CA лежат в `/etc/trainer-ca/`.
Сейчас `curl https://secure.trainer.local:8443/` падает с ошибкой сертификата, а по HTTP
сайт открывается без шифрования.

## Задача
1. Выпусти для `secure.trainer.local` новый сертификат, подписанный корпоративным CA,
   со сроком действия не меньше 30 дней и с правильным SAN.
2. Настрой nginx на новый сертификат.
3. Сделай так, чтобы **этот сервер** доверял корпоративному CA (curl без `-k`).
4. HTTP должен отвечать редиректом 301 на `https://secure.trainer.local:8443/...`.

## Ограничения
- Не использовать `curl -k` / `--insecure` и не отключать проверку сертификатов.
- Сертификат подписан корпоративным CA, а не самоподписанный.

## Критерии готовности (что проверяет check)
- `curl https://secure.trainer.local:8443/` без `-k` → 200
- сертификат содержит `DNS:secure.trainer.local` в SAN и действует ещё больше 30 дней
- `http://secure.trainer.local:8105/x` → 301 на `https://secure.trainer.local:8443/x`

> Теория по теме — [THEORY.md](THEORY.md) (`sudo ./trainer.sh theory nginx-05`).
> Не читай `break.sh` и `check.sh` — там спойлеры.
