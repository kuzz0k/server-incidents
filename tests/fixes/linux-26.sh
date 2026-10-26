#!/usr/bin/env bash
# Эталонное решение linux-26 (для tests/selftest.sh)
set -euo pipefail
mkdir -p /var/lib/swap
fallocate -l 512M /var/lib/swap/trainer.swap
chmod 600 /var/lib/swap/trainer.swap
mkswap -q /var/lib/swap/trainer.swap
swapon /var/lib/swap/trainer.swap
echo '/var/lib/swap/trainer.swap none swap sw 0 0' >> /etc/fstab
echo 'vm.swappiness=10' > /etc/sysctl.d/90-swappiness.conf
sysctl -q --system
