# nginx-03 · Разбор

## Шаги диагностики
1. `tail -f /var/log/nginx/error.log` и `curl -i http://127.0.0.1:8103/`:
   `open() "/srv/www/blog/index.html" failed (13: Permission denied)` или `"/srv/www/blog/" is forbidden (13: Permission denied)`.
2. `namei -l /srv/www/blog` — у `/srv/www` права `drwx------ root`: worker nginx (`www-data`) не может «пройти» через каталог (нужен `x`).
3. Проверить от имени nginx: `sudo -u www-data ls /srv/www/blog`.
4. После прав: `directory index of "/srv/www/blog/" is forbidden` — в каталоге нет `index.html`, а в `index` указан только он. Есть `index.htm`.
5. Картинки: в error.log `open() "/srv/media/imageslogo.png" failed (2: No such file)` — `alias` без завершающего `/`.

## Решение
```bash
chmod 755 /srv/www
sed -i 's/index index.html;/index index.html index.htm;/' /etc/nginx/sites-available/blog
sed -i 's|alias /srv/media/images;|alias /srv/media/images/;|' /etc/nginx/sites-available/blog
nginx -t && systemctl reload nginx
curl -I http://127.0.0.1:8103/ http://127.0.0.1:8103/images/logo.png
```

## Как не допустить снова
- Для `location /x/` с `alias` всегда ставить слэш в конце обоих. Если путь совпадает с URI — лучше `root`.
- При переносе сохранять права, проверять через `sudo -u www-data`.

## Доп. вопросы на собеседовании
- Чем `root` отличается от `alias`?
- Как nginx выбирает location? Порядок: `=`, `^~`, регулярки `~`/`~*`, самый длинный префикс.
- Что делает `try_files $uri $uri/ /index.html` и зачем это SPA?
- Когда nginx отдаёт 403, а когда 404 для отсутствующего файла? Что делает `autoindex`?
- Как отдавать статику эффективно? (`sendfile`, `expires`, gzip, `open_file_cache`)
