#!/usr/bin/env python3
"""Демо-сервис тренажёра (только stdlib).

Все настройки — переменные окружения. Если задан CONFIG, то файл key=value
читается поверх окружения (ключи приводятся к верхнему регистру).

  NAME            имя сервиса в ответах и логах            (default: webapp)
  BIND / PORT     адрес и порт                               (0.0.0.0 / 8080)
  BODY            тело ответа на GET                         ("<NAME> ok")
  REQUIRE         обязательные ключи через запятую
  DATA_DIR        каталог данных: /health проверяет запись, POST /write пишет файл
  CACHE_MB        сколько МБ памяти занять при старте
  OPEN_FDS        сколько файловых дескрипторов открыть при старте
  ROUTES          разрешённые префиксы путей через запятую, остальное 404
  REQUIRE_HEADER  заголовок, без которого запрос получает 400
  SLOW            медленные пути: "/report:8,/export:3" — пауза в секундах перед ответом
  METRICS         1 — отдавать метрики Prometheus на /metrics
"""
import os
import signal
import sys
import tempfile
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


def log(msg):
    print(f"{time.strftime('%Y-%m-%dT%H:%M:%S')} {msg}", flush=True)


def die(msg):
    print(f"FATAL: {msg}", file=sys.stderr, flush=True)
    sys.exit(1)


def load_config():
    cfg = dict(os.environ)
    path = os.environ.get("CONFIG")
    if path:
        try:
            with open(path) as f:
                lines = f.readlines()
        except OSError as e:
            die(f"cannot read config {path}: {e}")
        for n, line in enumerate(lines, 1):
            s = line.strip()
            if not s or s.startswith("#"):
                continue
            if "=" not in s:
                die(f"config parse error in {path} line {n}: {s!r} (expected key=value)")
            k, v = s.split("=", 1)
            cfg[k.strip().upper()] = v.strip()
    for key in filter(None, (k.strip() for k in cfg.get("REQUIRE", "").split(","))):
        if not cfg.get(key):
            die(f"required setting {key} is not set")
    return cfg


def as_int(cfg, key, default):
    raw = cfg.get(key, str(default))
    try:
        return int(raw)
    except ValueError:
        die(f"setting {key} must be an integer, got {raw!r}")


CFG = load_config()
NAME = CFG.get("NAME", "webapp")
BIND = CFG.get("BIND", "0.0.0.0")
PORT = as_int(CFG, "PORT", 8080)
BODY = CFG.get("BODY", f"{NAME} ok")
DATA_DIR = CFG.get("DATA_DIR", "")
ROUTES = [r for r in (x.strip() for x in CFG.get("ROUTES", "").split(",")) if r]
REQUIRE_HEADER = CFG.get("REQUIRE_HEADER", "")
SLOW = {}
for item in filter(None, (x.strip() for x in CFG.get("SLOW", "").split(","))):
    path, _, sec = item.partition(":")
    SLOW[path] = float(sec or 0)
METRICS = CFG.get("METRICS", "") == "1"
STARTED = time.time()
REQUESTS = 0

_cache = None
_fds = []


def allocate():
    global _cache
    mb = as_int(CFG, "CACHE_MB", 0)
    if mb > 0:
        log(f"warming cache: {mb} MB")
        _cache = bytearray(mb * 1024 * 1024)
        for i in range(0, len(_cache), 4096):
            _cache[i] = 1
    n = as_int(CFG, "OPEN_FDS", 0)
    for i in range(n):
        try:
            _fds.append(open("/dev/null", "rb"))
        except OSError as e:
            die(f"cannot open connection #{i + 1} of {n}: {e}")
    if n:
        log(f"opened {n} connections")


def data_dir_writable():
    if not DATA_DIR:
        return True, ""
    try:
        fd, path = tempfile.mkstemp(prefix=".health-", dir=DATA_DIR)
        try:
            os.write(fd, b"x" * 4096)
            os.fsync(fd)
        finally:
            os.close(fd)
            os.unlink(path)
        return True, ""
    except OSError as e:
        return False, str(e)


class Handler(BaseHTTPRequestHandler):
    server_version = NAME

    def log_message(self, fmt, *args):
        log(f"{self.client_address[0]} {fmt % args}")

    def reply(self, code, text):
        data = (text + "\n").encode()
        self.send_response(code)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def precheck(self):
        if REQUIRE_HEADER and not self.headers.get(REQUIRE_HEADER):
            log(f"rejecting {self.path}: missing header {REQUIRE_HEADER}")
            self.reply(400, f"missing required header {REQUIRE_HEADER}")
            return False
        if ROUTES and self.path != "/health" and not any(self.path.startswith(r) for r in ROUTES):
            self.reply(404, f"{NAME}: no route for {self.path}")
            return False
        return True

    def do_GET(self):
        global REQUESTS
        REQUESTS += 1
        delay = next((s for p, s in SLOW.items() if self.path.startswith(p)), 0)
        if delay:
            time.sleep(delay)
        if METRICS and self.path == "/metrics":
            self.reply(200, "\n".join([
                "# HELP app_requests_total Total HTTP requests.",
                "# TYPE app_requests_total counter",
                f'app_requests_total{{app="{NAME}"}} {REQUESTS}',
                "# HELP app_uptime_seconds Process uptime.",
                "# TYPE app_uptime_seconds gauge",
                f'app_uptime_seconds{{app="{NAME}"}} {time.time() - STARTED:.0f}',
            ]))
            return
        if self.path == "/health":
            ok, err = data_dir_writable()
            if ok:
                self.reply(200, "ok")
            else:
                log(f"ERROR data dir {DATA_DIR} is not writable: {err}")
                self.reply(500, f"data dir not writable: {err}")
            return
        if self.precheck():
            self.reply(200, f"{BODY} path={self.path}")

    def do_POST(self):
        length = int(self.headers.get("Content-Length") or 0)
        body = self.rfile.read(length) if length else b""
        if self.path == "/write":
            if not DATA_DIR:
                self.reply(400, "DATA_DIR is not configured")
                return
            try:
                os.makedirs(os.path.join(DATA_DIR, "uploads"), exist_ok=True)
                name = os.path.join(DATA_DIR, "uploads", f"{time.time_ns()}.txt")
                with open(name, "wb") as f:
                    f.write(body or b"report\n")
                self.reply(201, f"saved {name}")
            except OSError as e:
                log(f"ERROR cannot save report: {e}")
                self.reply(500, f"cannot save: {e}")
            return
        if self.precheck():
            self.reply(200, f"{NAME} received {len(body)} bytes path={self.path}")


def main():
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    allocate()
    try:
        srv = ThreadingHTTPServer((BIND, PORT), Handler)
    except OSError as e:
        die(f"cannot bind {BIND}:{PORT}: {e}")
    log(f"{NAME} listening on {BIND}:{PORT}")
    ok, err = data_dir_writable()
    if not ok:
        log(f"ERROR data dir {DATA_DIR} is not writable: {err}")
    srv.serve_forever()


if __name__ == "__main__":
    main()
