#!/usr/bin/env bash
# Эталонное решение docker-06 (для tests/selftest.sh)
set -euo pipefail
cd /opt/trainer-docker/worker
sed -i 's/\r$//' entrypoint.sh
sed -i '1s|^#!/bin/bash|#!/bin/sh|' entrypoint.sh
