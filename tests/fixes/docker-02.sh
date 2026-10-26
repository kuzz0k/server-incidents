#!/usr/bin/env bash
# Эталонное решение docker-02 (для tests/selftest.sh)
set -euo pipefail
sed -i 's|-p 8202:8080 trainer/catalog:1.0|-e BIND=0.0.0.0 -p 8202:5000 trainer/catalog:1.0|' /opt/trainer-docker/catalog/run.sh
